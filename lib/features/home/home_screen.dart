import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../transfers/transfer_screen.dart';
import '../services/services_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream a Firestore (users -> uid -> transactions)
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('transactions')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error de conexión"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Cálculo de saldo en el cliente
          double saldo = 0;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0).toDouble();
            if (data['type'] == 'income') {
              saldo += amount;
            } else {
              saldo -= amount;
            }
          }

          return Column(
            children: [
              _buildBalanceCard(context, saldo),
              const SizedBox(height: 20),
              _buildActionButtons(context, user.uid),
              const SizedBox(height: 30),
              _buildMovementsHeader(),
              const SizedBox(height: 10),
              _buildMovementsList(docs),
            ],
          );
        },
      ),
    );
  }

  // Tarjeta Morada de Saldo
  Widget _buildBalanceCard(BuildContext context, double saldo) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.balanceTitle,
                  style: TextStyle(color: Colors.white70)),
              // Ocultar saldo (Visual, sin lógica por ahora)
              Icon(Icons.remove_red_eye_outlined, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "S/ ${saldo.toStringAsFixed(2)}",
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Botonera de Acciones
  Widget _buildActionButtons(BuildContext context, String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionButton(
              icon: Icons.qr_code_scanner,
              label: AppStrings.actionScan,
              onTap: () {} // TODO: Implementar QR
              ),
          _ActionButton(
            icon: Icons.send_to_mobile, // Ícono de "Pavear"
            label: AppStrings.actionPavear,
            isPrimary: true, // Lo destacamos
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TransferScreen())),
          ),
          _ActionButton(
            icon: Icons.lightbulb_outline,
            label: AppStrings.actionServices,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ServicesScreen())),
          ),
          _ActionButton(
            icon: Icons.add_circle_outline,
            label: AppStrings.actionRecharge,
            onTap: () => _addMoney(context, uid), // Truco para recargar
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(AppStrings.lastMovements,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMovementsList(List<QueryDocumentSnapshot> docs) {
    return Expanded(
      child: docs.isEmpty
          ? const Center(child: Text(AppStrings.noMovements))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final bool isExpense = data['type'] == 'expense';
                final date =
                    (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isExpense ? Colors.red[50] : Colors.green[50],
                      child: Icon(
                        isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isExpense ? Colors.red : Colors.green,
                        size: 20,
                      ),
                    ),
                    title: Text(data['description'] ?? 'Movimiento',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(DateFormat('dd MMM - HH:mm').format(date),
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                    trailing: Text(
                      "${isExpense ? '-' : '+'} S/ ${data['amount']}",
                      style: TextStyle(
                          color: isExpense ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Función "Truco" para recargar saldo (Solo desarrollo)
  Future<void> _addMoney(BuildContext context, String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add({
      'type': 'income',
      'amount': 100.00,
      'description': 'Recarga PavoEfectivo',
      'date': FieldValue.serverTimestamp(),
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Recarga de S/ 100 exitosa!")));
    }
  }
}

// Widget interno reutilizable
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: isPrimary
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (isPrimary)
                    BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  else
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                ]),
            child: Icon(icon,
                color: isPrimary
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

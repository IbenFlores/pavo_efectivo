import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isLoading = false;
  String? _statusMessage;
  bool _isError = false;

  Future<void> _makeTransfer() async {
    // Validaciones iniciales
    final amount = double.tryParse(_amountController.text);
    final targetEmail = _emailController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ingresa un monto válido")));
      return;
    }
    if (targetEmail.isEmpty || targetEmail == currentUser!.email) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Correo inválido o eres tú mismo")));
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Buscando usuario...";
      _isError = false;
    });

    try {
      final db = FirebaseFirestore.instance;

      // 1. Buscar al destinatario en la colección 'users'
      final querySnapshot = await db
          .collection('users')
          .where('email', isEqualTo: targetEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw "El usuario con correo $targetEmail no existe en PavoEfectivo.";
      }

      final targetUserDoc = querySnapshot.docs.first;
      final targetUid = targetUserDoc.id;

      setState(() => _statusMessage = "Procesando transferencia...");

      // 2. Realizar la transacción (Batch Write para atomicidad)
      final batch = db.batch();

      // A: Restar saldo al remitente (Expense)
      final senderRef = db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('transactions')
          .doc();
      batch.set(senderRef, {
        'type': 'expense',
        'amount': amount,
        'description': 'Transferencia a $targetEmail',
        'date': FieldValue.serverTimestamp(),
      });

      // B: Sumar saldo al destinatario (Income)
      final receiverRef = db
          .collection('users')
          .doc(targetUid)
          .collection('transactions')
          .doc();
      batch.set(receiverRef, {
        'type': 'income',
        'amount': amount,
        'description': 'Recibido de ${currentUser.email}',
        'date': FieldValue.serverTimestamp(),
      });

      // Ejecutar todo junto
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("¡Enviaste S/ $amount exitosamente!")));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _statusMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transferir")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Destinatario",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Ingresa el correo del usuario",
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Monto a transferir",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
              decoration: const InputDecoration(
                prefixText: "S/ ",
                hintText: "0.00",
              ),
            ),
            const SizedBox(height: 30),

            // Mensajes de estado
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: _isError ? Colors.red[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(_isError ? Icons.error : Icons.info,
                        color: _isError ? Colors.red : Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(_statusMessage!,
                            style: TextStyle(
                                color: _isError
                                    ? Colors.red[900]
                                    : Colors.blue[900]))),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isLoading ? null : _makeTransfer,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Pavear Dinero",
                        style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

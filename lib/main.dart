import 'package:flutter/material.dart';

void main() {
  runApp(const TrustEscrowApp());
}

class TrustEscrowApp extends StatelessWidget {
  const TrustEscrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrustEscrow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// MODELS
// -----------------------------------------------------------------------------
enum EscrowRole { buyer, seller }
enum EscrowStatus { pending, funded, completed, disputed }

class EscrowTransaction {
  final String id;
  final String title;
  final double amount;
  final String partyName;
  final EscrowRole myRole;
  EscrowStatus status;

  EscrowTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.partyName,
    required this.myRole,
    this.status = EscrowStatus.pending,
  });
}

// -----------------------------------------------------------------------------
// 1. SIGN IN / REGISTER SCREEN
// -----------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _submitAuth() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    // Navigate to Dashboard upon Sign In / Register
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          userName: _nameController.text.isNotEmpty ? _nameController.text : 'Prerak',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.security_outlined, size: 72, color: Color(0xFF6750A4)),
              const SizedBox(height: 12),
              Text(
                'TrustEscrow',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6750A4),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                isLogin ? 'Sign in to access your escrows' : 'Create an account to get started',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              if (!isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Don't have an account? Register" : "Already have an account? Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. DASHBOARD SCREEN
// -----------------------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<EscrowTransaction> _escrows = [
    EscrowTransaction(
      id: '1',
      title: 'Gaming Laptop Deal',
      amount: 450.00,
      partyName: 'alex@example.com',
      myRole: EscrowRole.buyer,
      status: EscrowStatus.funded,
    ),
    EscrowTransaction(
      id: '2',
      title: 'Flutter App Design',
      amount: 150.00,
      partyName: 'sam_seller',
      myRole: EscrowRole.seller,
      status: EscrowStatus.pending,
    ),
  ];

  double get _protectedBalance {
    return _escrows
        .where((e) => e.status == EscrowStatus.funded)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  void _addEscrow(EscrowTransaction newEscrow) {
    setState(() => _escrows.add(newEscrow));
  }

  void _updateStatus(String id, EscrowStatus newStatus) {
    setState(() {
      final item = _escrows.firstWhere((e) => e.id == id);
      item.status = newStatus;
    });
  }

  void _openCreateEscrowModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => CreateEscrowSheet(onAdd: _addEscrow),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.userName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateEscrowModal,
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Escrow'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6750A4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Protected Balance in Escrow', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('\$${_protectedBalance.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Active Escrows', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_escrows.isEmpty)
              const Center(
                padding: EdgeInsets.all(32),
                child: Text('No active escrows yet. Tap + New Escrow to start.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _escrows.length,
                itemBuilder: (context, index) {
                  final escrow = _escrows[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(escrow.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Chip(
                                label: Text(
                                  escrow.myRole == EscrowRole.buyer ? 'BUYER' : 'SELLER',
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
                                ),
                                backgroundColor: escrow.myRole == EscrowRole.buyer ? Colors.blue : Colors.orange,
                              ),
                            ],
                          ),
                          Text('\$${escrow.amount.toStringAsFixed(2)} • ${escrow.partyName}',
                              style: TextStyle(color: Colors.grey[700])),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Status: ', style: TextStyle(fontSize: 12)),
                              Text(
                                escrow.status.name.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: escrow.status == EscrowStatus.funded
                                      ? Colors.green
                                      : (escrow.status == EscrowStatus.disputed ? Colors.red : Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          // Action buttons based on state
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (escrow.status == EscrowStatus.pending && escrow.myRole == EscrowRole.buyer)
                                ElevatedButton(
                                  onPressed: () => _updateStatus(escrow.id, EscrowStatus.funded),
                                  child: const Text('Deposit Funds'),
                                ),
                              if (escrow.status == EscrowStatus.funded && escrow.myRole == EscrowRole.buyer) ...[
                                TextButton(
                                  onPressed: () => _updateStatus(escrow.id, EscrowStatus.disputed),
                                  child: const Text('Dispute', style: TextStyle(color: Colors.red)),
                                ),
                                ElevatedButton(
                                  onPressed: () => _updateStatus(escrow.id, EscrowStatus.completed),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  child: const Text('Release Funds'),
                                ),
                              ],
                              if (escrow.status == EscrowStatus.completed)
                                const Text('Completed ✓', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              if (escrow.status == EscrowStatus.disputed)
                                const Text('Under Dispute Review ⚠️', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. CREATE NEW ESCROW MODAL SHEET
// -----------------------------------------------------------------------------
class CreateEscrowSheet extends StatefulWidget {
  final Function(EscrowTransaction) onAdd;
  const CreateEscrowSheet({super.key, required this.onAdd});

  @override
  State<CreateEscrowSheet> createState() => _CreateEscrowSheetState();
}

class _CreateEscrowSheetState extends State<CreateEscrowSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _partyController = TextEditingController();
  EscrowRole _selectedRole = EscrowRole.buyer;

  void _submit() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final party = _partyController.text;

    if (title.isEmpty || amount <= 0 || party.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid escrow details.')),
      );
      return;
    }

    widget.onAdd(
      EscrowTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        partyName: party,
        myRole: _selectedRole,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create New Escrow', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Role Selection
          Row(
            children: [
              const Text('My Role: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: SegmentedButton<EscrowRole>(
                  segments: const [
                    ButtonSegment(value: EscrowRole.buyer, label: Text('I am Buyer')),
                    ButtonSegment(value: EscrowRole.seller, label: Text('I am Seller')),
                  ],
                  selected: {_selectedRole},
                  onSelectionChanged: (newSelection) {
                    setState(() => _selectedRole = newSelection.first);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title / Item Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (\$)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _partyController,
            decoration: InputDecoration(
              labelText: _selectedRole == EscrowRole.buyer ? 'Seller Email / Name' : 'Buyer Email / Name',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6750A4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Initiate Escrow'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/wallet_service.dart';

class MyWallet extends StatefulWidget {
  final int userId;

  const MyWallet({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  // بيانات المستخدم
  double balance = 0.0;
  double pendingFees = 0.0;
  double effectiveBalance = 0.0;
  String currency = "د.ع";
  String userName = "";
  bool isLoading = true;
  bool isDepositing = false; // متغير لتتبع حالة الإيداع

  // بيانات المعاملات
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  // دالة لتنسيق الأرقام مع الفواصل
  String _formatNumber(double number) {
    try {
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return formatter.format(number);
    } catch (e) {
      return number.toStringAsFixed(2);
    }
  }

  Future<void> _loadWalletData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await WalletService.getWalletData(widget.userId);

      if (result['status'] == 'success' && result['data'] != null) {
        final data = result['data'];

        if (data['wallet'] != null) {
          setState(() {
            balance = double.tryParse(data['wallet']['wallet_balance']?.toString() ?? '0') ?? 0.0;
            pendingFees = double.tryParse(data['wallet']['pending_fees']?.toString() ?? '0') ?? 0.0;
            effectiveBalance = double.tryParse(data['wallet']['effective_balance']?.toString() ?? '0') ?? 0.0;
            userName = data['wallet']['users_name']?.toString() ?? 'المستخدم';

            // تحويل المعاملات
            if (data['transactions'] != null && data['transactions'] is List) {
              transactions = (data['transactions'] as List).map((transaction) {
                try {
                  return {
                    'id': transaction['transaction_id']?.toString() ?? '',
                    'title': transaction['transaction_description']?.toString() ?? 'معاملة',
                    'amount': double.tryParse(transaction['transaction_amount']?.toString() ?? '0') ?? 0.0,
                    'date': DateTime.tryParse(transaction['transaction_created_at']?.toString() ?? '') ?? DateTime.now(),
                    'status': _getTransactionStatus(
                        transaction['transaction_type']?.toString() ?? '',
                        transaction['transaction_status']?.toString() ?? ''
                    ),
                    'type': transaction['transaction_type']?.toString() ?? ''
                  };
                } catch (e) {
                  return {
                    'id': '',
                    'title': 'معاملة',
                    'amount': 0.0,
                    'date': DateTime.now(),
                    'status': 'غير معروف',
                    'type': ''
                  };
                }
              }).toList();
            } else {
              transactions = [];
            }

            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorMessage('بيانات المحفظة غير متوفرة');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorMessage(result['message']?.toString() ?? 'حدث خطأ في تحميل البيانات');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorMessage('حدث خطأ في الاتصال: ${e.toString()}');
    }
  }

  String _getTransactionStatus(String type, String status) {
    if (status == 'completed') {
      switch (type) {
        case 'deposit':
          return 'مكتمل';
        case 'payment':
          return 'مدفوع';
        case 'refund':
          return 'مسترد';
        default:
          return 'مكتمل';
      }
    } else if (status == 'pending') {
      return 'معلق';
    } else {
      return 'فاشل';
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "المحفظة",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: isDepositing ? null : _loadWalletData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadWalletData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildWalletBalance(),
              _buildDepositButton(),
              if (pendingFees > 0) _buildPendingFeesCard(),
              _buildTransactionsHeader(),
              _buildTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }

  // بناء قسم رصيد المحفظة
  Widget _buildWalletBalance() {
    bool isNegative = effectiveBalance < 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isNegative
              ? [const Color(0xFFE53935), const Color(0xFFD32F2F)]
              : [const Color(0xFF43A047), const Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isNegative
                ? Colors.red.withOpacity(0.3)
                : Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNegative ? "الديون المستحقة" : "رصيدك الحالي",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isNegative ? Icons.warning : Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isNegative ? "مدين" : "دائن",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  isNegative ? _formatNumber(effectiveBalance.abs()) : _formatNumber(effectiveBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                currency,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Text(
                "تم التحديث",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('hh:mm a').format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // كارد الرسوم المستحقة
  Widget _buildPendingFeesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "رسوم مستحقة",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "${_formatNumber(pendingFees)} $currency",
                  style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              "سيتم الخصم تلقائياً عند الإيداع",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // زر الإيداع
  Widget _buildDepositButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDepositing ? null : () {
          _showDepositDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDepositing ? Colors.grey : Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isDepositing
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              "جاري المعالجة...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "إيداع رصيد",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عنوان قائمة المعاملات
  Widget _buildTransactionsHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "المعاملات السابقة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${transactions.length} معاملة",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // قائمة المعاملات
  Widget _buildTransactionsList() {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "لا توجد معاملات",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  // بناء عنصر المعاملة
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isPositive = (transaction["amount"] ?? 0.0) > 0;
    final String type = transaction["type"]?.toString() ?? "";

    IconData getIconByType() {
      switch (type) {
        case 'deposit':
          return Icons.arrow_downward;
        case 'payment':
          return Icons.payment;
        case 'refund':
          return Icons.refresh;
        default:
          return Icons.receipt;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة المعاملة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              getIconByType(),
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 14),
          // تفاصيل المعاملة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction["title"]?.toString() ?? "معاملة",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMMM، yyyy - hh:mm a').format(transaction["date"] ?? DateTime.now()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // مبلغ المعاملة
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isPositive ? '+' : ''}${_formatNumber(transaction["amount"] ?? 0.0)} $currency",
                style: TextStyle(
                  color: isPositive ? Colors.green[600] : Colors.red[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  transaction["status"]?.toString() ?? "غير معروف",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // مربع حوار إضافة رصيد - تصميم حديث ومتطور
  void _showDepositDialog() {
    if (isDepositing) return;

    TextEditingController amountController = TextEditingController();
    List<double> quickAmounts = [5000, 10000, 15000, 20000];
    double minAmount = 1000;
    int selectedIndex = -1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF4CAF50)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "إيداع رصيد",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                "اختر المبلغ المناسب لك",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: isDepositing ? null : () {
                            Navigator.pop(context);
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick amounts
                          const Text(
                            "المبالغ السريعة",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 16),

                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: quickAmounts.length,
                            itemBuilder: (context, index) {
                              final amount = quickAmounts[index];
                              final isSelected = selectedIndex == index;

                              return GestureDetector(
                                onTap: isDepositing ? null : () {
                                  setDialogState(() {
                                    selectedIndex = index;
                                    amountController.text = amount.toInt().toString();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                      colors: [Color(0xFF00C853), Color(0xFF4CAF50)],
                                    )
                                        : null,
                                    color: isSelected ? null : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : const Color(0xFFE0E0E0),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: const Color(0xFF00C853).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          NumberFormat('#,###').format(amount.toInt()),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        Text(
                                          currency,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.8)
                                                : const Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Custom amount
                          const Text(
                            "مبلغ مخصص",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Decrease button
                                GestureDetector(
                                  onTap: isDepositing ? null : () {
                                    double currentAmount = double.tryParse(amountController.text) ?? 0;
                                    if (currentAmount >= 2000) {
                                      setDialogState(() {
                                        selectedIndex = -1;
                                        amountController.text = (currentAmount - 1000).toInt().toString();
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        color: Colors.red[600],
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),

                                // Amount input
                                Expanded(
                                  child: TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    enabled: !isDepositing,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "1000",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 20,
                                      ),
                                      border: InputBorder.none,
                                      suffixText: currency,
                                      suffixStyle: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setDialogState(() {
                                        selectedIndex = -1;
                                      });
                                    },
                                  ),
                                ),

                                // Increase button
                                GestureDetector(
                                  onTap: isDepositing ? null : () {
                                    double currentAmount = double.tryParse(amountController.text) ?? 0;
                                    setDialogState(() {
                                      selectedIndex = -1;
                                      amountController.text = (currentAmount + 1000).toInt().toString();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.green[600],
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Minimum amount info
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "الحد الأدنى للإيداع: ${NumberFormat('#,###').format(minAmount.toInt())} $currency",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Balance info
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2196F3).withOpacity(0.1),
                                  const Color(0xFF1976D2).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2196F3).withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "الرصيد الحالي",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    Text(
                                      "${_formatNumber(balance)} $currency",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                                if (pendingFees > 0) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "رسوم مستحقة",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      Text(
                                        "${_formatNumber(pendingFees)} $currency",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE53935),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          if (isDepositing) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFFB74D).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      "جاري معالجة العملية، يرجى الانتظار...",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Bottom action
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isDepositing ? null : () async {
                            String amountText = amountController.text.trim();
                            if (amountText.isNotEmpty) {
                              double? amount = double.tryParse(amountText);
                              if (amount != null && amount >= minAmount) {
                                setState(() {
                                  isDepositing = true;
                                });
                                setDialogState(() {});

                                try {
                                  final result = await WalletService.depositMoney(
                                      widget.userId,
                                      amount,
                                      "تم إيداع رصيد"
                                  );

                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }

                                  if (result['status'] == 'success') {
                                    _showSuccessMessage(result['message']?.toString() ?? 'تم إيداع المبلغ بنجاح');
                                    await _loadWalletData();
                                  } else {
                                    _showErrorMessage(result['message']?.toString() ?? 'فشل في إيداع المبلغ');
                                  }
                                } catch (e) {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                  _showErrorMessage('حدث خطأ أثناء العملية: ${e.toString()}');
                                } finally {
                                  setState(() {
                                    isDepositing = false;
                                  });
                                }
                              } else {
                                _showErrorMessage('الحد الأدنى للإيداع هو ${NumberFormat('#,###').format(minAmount.toInt())} $currency');
                              }
                            } else {
                              _showErrorMessage('يرجى إدخال المبلغ');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDepositing
                                ? Colors.grey[400]
                                : const Color(0xFF00C853),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isDepositing
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            "إيداع الآن",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

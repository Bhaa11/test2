import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constant/color.dart';

class CarSelectionDialog extends StatefulWidget {
  final Map<String, Map<String, List<String>>> carData;
  final String? initialCompany;
  final String? initialModel;
  final String? initialYear;

  const CarSelectionDialog({
    super.key,
    required this.carData,
    this.initialCompany,
    this.initialModel,
    this.initialYear,
  });

  static Future<Map<String, String?>?> show({
    required BuildContext context,
    required Map<String, Map<String, List<String>>> carData,
    String? initialCompany,
    String? initialModel,
    String? initialYear,
  }) async {
    // Set preferred orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: CarSelectionDialog(
          carData: carData,
          initialCompany: initialCompany,
          initialModel: initialModel,
          initialYear: initialYear,
        ),
      ),
    );

    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    return result;
  }

  @override
  State<CarSelectionDialog> createState() => _CarSelectionDialogState();
}

class _CarSelectionDialogState extends State<CarSelectionDialog>
    with SingleTickerProviderStateMixin {
  String? selectedCompany;
  String? selectedModel;
  String? selectedYear;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    selectedCompany = widget.initialCompany;
    selectedModel = widget.initialModel;
    selectedYear = widget.initialYear;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSelectionSteps(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSelections(),
                          const SizedBox(height: 24),
                          _buildConfirmButton(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.primaryColor, AppColor.secondColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
        ),

        // Close button
        Positioned(
          top: 16,
          left: 16,
          child: Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                _animController.reverse().then((_) => Navigator.pop(context));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),

        // Header content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'حدد نوع سيارتك'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'سنعرض لك جميع قطع الغيار المتوافقة'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionSteps() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          _buildStepIndicator(
              1,
              'الشركة'.tr,
              selectedCompany != null,
              isActive: true
          ),
          _buildStepConnector(selectedCompany != null),
          _buildStepIndicator(
              2,
              'الموديل'.tr,
              selectedModel != null,
              isActive: selectedCompany != null
          ),
          _buildStepConnector(selectedModel != null),
          _buildStepIndicator(
              3,
              'السنة'.tr,
              selectedYear != null,
              isActive: selectedModel != null
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isCompleted, {bool isActive = false}) {
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColor.primaryColor
                  : isActive
                  ? AppColor.primaryColor.withOpacity(0.1)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: isActive && !isCompleted
                  ? Border.all(color: AppColor.primaryColor, width: 2)
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                '$step',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive && !isCompleted
                      ? AppColor.primaryColor
                      : isActive
                      ? Colors.grey.shade800
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
              color: isActive || isCompleted ? AppColor.grey2 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isCompleted) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isCompleted ? AppColor.primaryColor : Colors.grey.shade300,
    );
  }

  Widget _buildSelections() {
    return Column(
      children: [
        _buildSelector(
          icon: Icons.business_rounded,
          title: 'الشركة المصنعة'.tr,
          value: selectedCompany,
          hint: 'اختر الشركة المصنعة'.tr,
          items: widget.carData.keys.toList(),
          onSelected: (value) {
            setState(() {
              selectedCompany = value;
              selectedModel = null;
              selectedYear = null;
            });
          },
          isActive: true,
        ),
        const SizedBox(height: 16),
        _buildSelector(
          icon: Icons.directions_car_filled,
          title: 'موديل السيارة'.tr,
          value: selectedModel,
          hint: 'اختر الموديل'.tr,
          items: selectedCompany != null ? widget.carData[selectedCompany]!.keys.toList() : [],
          onSelected: (value) {
            setState(() {
              selectedModel = value;
              selectedYear = null;
            });
          },
          isActive: selectedCompany != null,
        ),
        const SizedBox(height: 16),
        _buildSelector(
          icon: Icons.calendar_today_rounded,
          title: 'سنة الصنع'.tr,
          value: selectedYear,
          hint: 'اختر سنة الصنع'.tr,
          items: selectedModel != null
              ? widget.carData[selectedCompany]![selectedModel]!
              : [],
          onSelected: (value) {
            setState(() => selectedYear = value);
          },
          isActive: selectedModel != null,
        ),
      ],
    );
  }

  Widget _buildSelector({
    required IconData icon,
    required String title,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onSelected,
    required bool isActive,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: isActive ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 8),
            child: Row(
              children: [
                Icon(icon, color: AppColor.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColor.grey2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isActive ? () async {
              final result = await _showSelectionSheet(title, items, value);
              if (result != null) onSelected(result);
            } : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? value != null
                      ? AppColor.primaryColor.withOpacity(0.5)
                      : Colors.grey.shade300
                      : Colors.grey.shade200,
                  width: value != null && isActive ? 1.5 : 1,
                ),
                color: isActive
                    ? value != null
                    ? AppColor.primaryColor.withOpacity(0.05)
                    : Colors.grey.shade50
                    : Colors.grey.shade100,
                boxShadow: value != null && isActive
                    ? [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.keyboard_arrow_down_rounded : Icons.lock_outline_rounded,
                    color: isActive
                        ? value != null
                        ? AppColor.primaryColor
                        : Colors.grey.shade400
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value ?? hint,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        color: value == null
                            ? isActive
                            ? Colors.grey.shade600
                            : Colors.grey.shade500
                            : AppColor.grey2,
                        fontWeight: value == null ? FontWeight.normal : FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final enabled = selectedCompany != null && selectedModel != null && selectedYear != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: enabled
            ? LinearGradient(
          colors: [AppColor.primaryColor, AppColor.secondColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: enabled ? null : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled
              ? () {
            _animController.reverse().then((_) {
              Navigator.pop(context, {
                'company': selectedCompany,
                'model': selectedModel,
                'year': selectedYear,
              });
            });
          }
              : null,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تأكيد الاختيار'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: enabled ? Colors.white : Colors.grey.shade500,
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showSelectionSheet(
      String title,
      List<String> items,
      String? selected,
      ) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SelectionSheet(
          title: title,
          items: items,
          selected: selected,
        );
      },
    );
  }
}

class _SelectionSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selected;

  const _SelectionSheet({
    Key? key,
    required this.title,
    required this.items,
    this.selected,
  }) : super(key: key);

  @override
  _SelectionSheetState createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<_SelectionSheet> with SingleTickerProviderStateMixin {
  late List<String> filtered;
  String query = '';
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    filtered = List.from(widget.items);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set a fixed height that doesn't resize with keyboard
    final double sheetHeight = MediaQuery.of(context).size.height * 0.7;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animController.value) * (sheetHeight * 0.25)),
          child: Opacity(
            opacity: _animController.value,
            child: child,
          ),
        );
      },
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primaryColor.withOpacity(0.9),
                    AppColor.secondColor.withOpacity(0.9)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                        onPressed: () {
                          _animController.reverse().then((_) => Navigator.pop(context));
                        },
                      ),
                      Text(
                        "اختر".tr + " ${widget.title}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ],
              ),
            ),

            // Search Box
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  autofocus: false,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن'.tr + ' ${widget.title}...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          query = '';
                          _searchController.clear();
                          filtered = widget.items;
                        });
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                  onChanged: (value) {
                    setState(() {
                      query = value;
                      filtered = widget.items
                          .where((e) => e.toLowerCase().contains(query.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
            ),

            // List of items - In an Expanded widget to take remaining space
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 54, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد نتائج للبحث'.tr,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'جرب كلمات بحث أخرى'.tr,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filtered.length,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final isSelected = item == widget.selected;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Material(
                      color: isSelected
                          ? AppColor.primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          _animController.reverse().then((_) => Navigator.pop(context, item));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColor.primaryColor,
                                  size: 22,
                                )
                              else
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColor.primaryColor
                                        : AppColor.grey2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

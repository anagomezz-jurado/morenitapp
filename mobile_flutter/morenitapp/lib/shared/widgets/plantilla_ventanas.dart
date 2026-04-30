import 'package:flutter/material.dart';
import 'package:morenitapp/shared/widgets/filtro_avanzado_model.dart';

// --- COMPONENTE PRINCIPAL: PLANTILLA VENTANAS ---
class PlantillaVentanas extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;
  final VoidCallback? onNuevo;
  final Function(String)? onSearch;
  final List<Widget> toolButtons;
  final Widget? filtrosAdicionales;
  final VoidCallback? onDownloadExcel;
  final VoidCallback? onDownloadPDF;
  final List<DataColumn>? columns;
  final List<DataRow>? rows;
  final String paginationText;
  final bool isLoading;
  final Widget? customBody;

  const PlantillaVentanas({
    super.key,
    required this.title,
    this.onRefresh,
    this.onNuevo,
    this.onSearch,
    this.onDownloadExcel,
    this.onDownloadPDF,
    this.filtrosAdicionales,
    this.toolButtons = const [],
    this.columns,
    this.rows,
    this.paginationText = '',
    this.isLoading = false,
    this.customBody,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(
                color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryColor),
        actions: [
          if (onRefresh != null)
            IconButton(
              tooltip: 'Refrescar datos',
              icon: Icon(Icons.refresh_rounded, color: primaryColor),
              onPressed: onRefresh,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // --- BARRA DE ACCIONES (ESTILO ODOO) ---
          if (onNuevo != null || onDownloadExcel != null || onSearch != null || filtrosAdicionales != null)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (onNuevo != null)
                        ElevatedButton.icon(
                          onPressed: onNuevo,
                          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          label: const Text('NUEVO'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      const SizedBox(width: 15),
                      if (onDownloadExcel != null)
                        _CircularIconButton(
                          icon: Icons.table_chart_outlined,
                          onTap: onDownloadExcel!,
                          tooltip: 'Descargar Excel',
                        ),
                      const SizedBox(width: 10),
                      if (onDownloadPDF != null)
                        _CircularIconButton(
                          icon: Icons.picture_as_pdf_outlined,
                          onTap: onDownloadPDF!,
                          tooltip: 'Descargar Informe PDF',
                        ),
                      const Spacer(),
                      if (onSearch != null)
                        _SearchBar(onSearch: onSearch!, primaryColor: primaryColor),
                    ],
                  ),
                  // Fila inferior para los filtros avanzados (ancho completo)
                  if (filtrosAdicionales != null) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.shade100),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: filtrosAdicionales!),
                  ],
                ],
              ),
            ),

         

          // --- CONTENIDO ---
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : (customBody ?? _buildDataTable(context, primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: const Color(0xFFF1F3F5)),
        child: SizedBox.expand(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 32,
                ),
                child: DataTable(
                  columnSpacing: 24,
                  horizontalMargin: 20,
                  headingRowHeight: 50,
                  dataRowHeight: 55,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                  headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.5),
                  columns: columns ?? [],
                  rows: rows ?? [],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// --- COMPONENTE DE FILTRADO AVANZADO (ESTILO ODOO) ---
// --- COMPONENTE DE FILTRADO AVANZADO (CORREGIDO) ---
class AdvancedFilterBar extends StatefulWidget {
  final List<Map<String, String>> fields;
  final Function(List<FilterCriterion>) onFiltersChanged;

  const AdvancedFilterBar({super.key, required this.fields, required this.onFiltersChanged});

  @override
  State<AdvancedFilterBar> createState() => _AdvancedFilterBarState();
}

class _AdvancedFilterBarState extends State<AdvancedFilterBar> {
  List<FilterCriterion> activeFilters = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PopupMenuButton(
          offset: const Offset(0, 45),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.filter_alt_outlined, size: 18, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text("Filtros", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
              ],
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => Future.delayed(Duration.zero, () => _showFilterDialog(context)),
              child: const Text("Añadir filtro personalizado"),
            ),
          ],
        ),
        ...activeFilters.asMap().entries.map((entry) {
          int idx = entry.key;
          FilterCriterion filter = entry.value;
          return Chip(
            backgroundColor: Colors.blue.shade50,
            side: BorderSide(color: Colors.blue.shade100),
            label: Text("${filter.label} ${_opLabel(filter.operator)} '${filter.value}'",
                style: TextStyle(color: Colors.blue.shade900, fontSize: 13)),
            onDeleted: () {
              setState(() => activeFilters.removeAt(idx));
              widget.onFiltersChanged(activeFilters);
            },
            deleteIcon: const Icon(Icons.close, size: 16),
          );
        }),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Valores iniciales
    String selectedFieldId = widget.fields.first['id']!;
    FilterOperator selectedOp = _getOperatorsForType(widget.fields.first['type']!).first;
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currentField = widget.fields.firstWhere((f) => f['id'] == selectedFieldId);
          final String fieldType = currentField['type'] ?? 'string';
          final bool isDate = fieldType == 'date';
          final bool isNumber = fieldType == 'number';

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Filtro personalizado"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Selector de Campo
                DropdownButtonFormField<String>(
                  value: selectedFieldId,
                  decoration: const InputDecoration(labelText: 'Campo', border: OutlineInputBorder()),
                  items: widget.fields.map((f) => DropdownMenuItem(value: f['id'], child: Text(f['name']!))).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      selectedFieldId = val!;
                      final newField = widget.fields.firstWhere((f) => f['id'] == val);
                      // Resetear operador y valor al cambiar de campo
                      selectedOp = _getOperatorsForType(newField['type']!).first;
                      valueController.clear(); 
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // 2. Selector de Operación
                DropdownButtonFormField<FilterOperator>(
                  value: selectedOp,
                  decoration: const InputDecoration(labelText: 'Operación', border: OutlineInputBorder()),
                  items: _getOperatorsForType(fieldType).map((op) => 
                    DropdownMenuItem(value: op, child: Text(_opLabel(op)))).toList(),
                  onChanged: (val) => setDialogState(() => selectedOp = val!),
                ),
                const SizedBox(height: 16),

                // 3. Input de Valor (Adaptativo)
                TextField(
                  controller: valueController,
                  readOnly: isDate, // Si es fecha, no dejamos escribir manual para evitar errores de formato
                  keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    hintText: isDate ? 'Seleccione una fecha' : 'Escriba aquí...',
                    border: const OutlineInputBorder(),
                    prefixIcon: isDate ? const Icon(Icons.calendar_month) : (isNumber ? const Icon(Icons.numbers) : null),
                  ),
                  onTap: isDate ? () async {
                    final date = await showDatePicker(
                      context: context, 
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900), 
                      lastDate: DateTime(2100)
                    );
                    if (date != null) {
                      // Formato YYYY-MM-DD estándar para bases de datos
                      setDialogState(() {
                        valueController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                      });
                    }
                  } : null,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 85, 42),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  if (valueController.text.isEmpty) return; // Evitar filtros vacíos

                  final newFilter = FilterCriterion(
                    field: selectedFieldId,
                    label: currentField['name']!,
                    operator: selectedOp,
                    value: valueController.text,
                    type: fieldType,
                  );
                  setState(() => activeFilters.add(newFilter));
                  widget.onFiltersChanged(activeFilters);
                  Navigator.pop(ctx);
                },
                child: const Text("APLICAR"),
              )
            ],
          );
        },
      ),
    );
  }

  List<FilterOperator> _getOperatorsForType(String type) {
    if (type == 'date' || type == 'number') {
      return [
        FilterOperator.equals, 
        FilterOperator.greaterThan, 
        FilterOperator.lessThan
      ];
    }
    return [FilterOperator.contains, FilterOperator.equals];
  }

  String _opLabel(FilterOperator op) {
    switch (op) {
      case FilterOperator.contains: return "contiene";
      case FilterOperator.equals: return "es igual a";
      case FilterOperator.greaterThan: return "es posterior/mayor que";
      case FilterOperator.lessThan: return "es anterior/menor que";
    }
  }
}

// --- COMPONENTE: BOTÓN CIRCULAR ---
class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _CircularIconButton({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDEE2E6)),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blueGrey, size: 22),
        ),
      ),
    );
  }
}

// --- COMPONENTE: BARRA DE BÚSQUEDA ---
class _SearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final Color primaryColor;

  const _SearchBar({required this.onSearch, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 40,
      child: TextField(
        onChanged: onSearch,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF1F3F5),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

// --- COMPONENTES MENORES ---
class _PaginationControl extends StatelessWidget {
  final String paginationText;
  final Color primaryColor;
  const _PaginationControl({required this.paginationText, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(paginationText, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
        const SizedBox(width: 8),
        Icon(Icons.chevron_left_rounded, color: primaryColor.withOpacity(0.5)),
        Icon(Icons.chevron_right_rounded, color: primaryColor),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ToolButton({required this.icon, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: Colors.blueGrey),
      label: Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
    );
  }
}
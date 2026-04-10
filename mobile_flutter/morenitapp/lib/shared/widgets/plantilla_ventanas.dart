import 'package:flutter/material.dart';

class PlantillaVentanas extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;
  final VoidCallback? onNuevo;
  final Function(String)? onSearch;
  final List<Widget> toolButtons;
  final Widget? filtrosAdicionales; // <--- NUEVO: Para inyectar Dropdowns de Provincia/Localidad
  final VoidCallback? onDownload;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String paginationText;
  final bool isLoading;

  const PlantillaVentanas({
    super.key,
    required this.title,
    this.onRefresh,
    this.onNuevo,
    this.onSearch,
    this.onDownload,
    this.filtrosAdicionales, // Parámetro opcional
    this.toolButtons = const [],
    required this.columns,
    required this.rows,
    this.paginationText = '',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
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
          // Barra de acciones principal
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
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
                
                if (onNuevo != null) const SizedBox(width: 15),

                if (onDownload != null)
                  _CircularIconButton(
                    icon: Icons.file_download_outlined,
                    onTap: onDownload!,
                    tooltip: 'Descargar Excel',
                  ),

                const SizedBox(width: 15),
                
                // Espacio para filtros dinámicos (Dropdowns de Provincia, etc)
                if (filtrosAdicionales != null) 
                  Expanded(child: filtrosAdicionales!),

                if (filtrosAdicionales == null) const Spacer(),
                
                if (onSearch != null)
                  _SearchBar(onSearch: onSearch!, primaryColor: primaryColor),
              ],
            ),
          ),
          
          // Barra de herramientas secundaria (Filtros, Agrupar, Paginación)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const _ToolButton(icon: Icons.filter_list_rounded, label: 'Filtros'),
                const SizedBox(width: 8),
                const _ToolButton(icon: Icons.account_tree_outlined, label: 'Agrupar'),
                ...toolButtons,
                const Spacer(),
                _PaginationControl(paginationText: paginationText, primaryColor: primaryColor),
              ],
            ),
          ),

          // Contenedor de la Tabla
          Expanded(
            child: Container(
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
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: const Color(0xFFF1F3F5),
                      ),
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
                                  letterSpacing: 0.5
                                ),
                                columns: columns,
                                rows: rows,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Componentes Privados Auxiliares ---

class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _CircularIconButton({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
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
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final Color primaryColor;

  const _SearchBar({required this.onSearch, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}

class _PaginationControl extends StatelessWidget {
  final String paginationText;
  final Color primaryColor;

  const _PaginationControl({required this.paginationText, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(paginationText, style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Icon(Icons.chevron_left_rounded, color: primaryColor.withOpacity(0.5), size: 22),
          Icon(Icons.chevron_right_rounded, color: primaryColor, size: 22),
        ],
      ),
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
      label: Text(label,
          style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w500)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
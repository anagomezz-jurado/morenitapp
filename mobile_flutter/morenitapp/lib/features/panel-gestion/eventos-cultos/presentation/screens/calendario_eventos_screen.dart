import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';

class CalendarioEventosScreen extends ConsumerStatefulWidget {
  const CalendarioEventosScreen({super.key});

  @override
  ConsumerState<CalendarioEventosScreen> createState() =>
      _CalendarioEventosScreenState();
}

class _CalendarioEventosScreenState
    extends ConsumerState<CalendarioEventosScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final secondary = colorScheme.secondary;
    final onPrimary = colorScheme.onPrimary;

    final eventosAsync = ref.watch(eventosProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Calendario de Cultos'),
        backgroundColor: primary,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(eventosProvider),
          ),
        ],
      ),
      body: eventosAsync.when(
        data: (eventos) {
          List<Evento> getEventosForDay(DateTime day) =>
              eventos.where((e) => isSameDay(e.fechaInicio, day)).toList();

          final eventosDelDia = getEventosForDay(_selectedDay ?? _focusedDay);

          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCalendar(
                  onPrimary: onPrimary,
                  primary: primary,
                  getEventosForDay: getEventosForDay,
                ),
              ),

              const SizedBox(height: 12),

              // Contador y Fecha
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.event, size: 16, color: secondary),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEEE d MMMM', 'es_ES')
                          .format(_selectedDay ?? _focusedDay),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${eventosDelDia.length} evento${eventosDelDia.length == 1 ? '' : 's'}',
                        style: TextStyle(
                            fontSize: 12,
                            color: secondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: _buildEventList(eventosDelDia, primary, secondary),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: primary)),
        error: (err, _) => Center(child: Text('Error al cargar eventos: $err')),
      ),
    );
  }

  Widget _buildCalendar({
    required Color onPrimary,
    required Color primary,
    required List<Evento> Function(DateTime) getEventosForDay,
  }) {
    return TableCalendar(
      locale: 'es_ES',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      eventLoader: getEventosForDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      headerStyle: HeaderStyle(
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: onPrimary.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: TextStyle(color: onPrimary, fontSize: 12),
        titleTextStyle: TextStyle(color: onPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        leftChevronIcon: Icon(Icons.chevron_left, color: onPrimary),
        rightChevronIcon: Icon(Icons.chevron_right, color: onPrimary),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: onPrimary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600),
        weekendStyle: TextStyle(color: onPrimary.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: onPrimary.withOpacity(0.25), shape: BoxShape.circle),
        todayTextStyle: TextStyle(color: onPrimary, fontWeight: FontWeight.bold),
        selectedDecoration: BoxDecoration(color: onPrimary, shape: BoxShape.circle),
        selectedTextStyle: TextStyle(color: primary, fontWeight: FontWeight.bold),
        defaultTextStyle: TextStyle(color: onPrimary.withOpacity(0.9)),
        weekendTextStyle: TextStyle(color: onPrimary.withOpacity(0.55)),
        outsideDaysVisible: false,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return const SizedBox();
          // 🔥 CORRECCIÓN: Usamos cast a <Evento> y accedemos a .colorVisual
          final visible = events.take(3).cast<Evento>().toList();

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: visible.map((e) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: e.colorVisual, // Directo desde el modelo
                  border: Border.all(color: onPrimary.withOpacity(0.4), width: 0.5),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<Evento> events, Color primary, Color secondary) {
    if (events.isEmpty) {
      return Center(
        child: Text('Sin eventos este día', style: TextStyle(color: secondary.withOpacity(0.5))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: events.length,
      itemBuilder: (context, i) {
        final e = events[i];
        // 🔥 CORRECCIÓN: Usamos e.colorVisual
        final colorTipo = e.colorVisual;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: colorTipo, width: 4)),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: colorTipo.withOpacity(0.15),
              child: Icon(Icons.church, color: colorTipo, size: 20),
            ),
            title: Text(
              e.nombre,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 12, color: secondary.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(e.tipoNombre, style: TextStyle(fontSize: 12, color: secondary.withOpacity(0.8))),
                  ],
                ),
                if (e.lugar != null && e.lugar!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: secondary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(e.lugar!, style: TextStyle(fontSize: 12, color: secondary.withOpacity(0.7))),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH:mm').format(e.fechaInicio),
                  style: TextStyle(color: colorTipo, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  DateFormat('HH:mm').format(e.fechaFin),
                  style: TextStyle(color: secondary.withOpacity(0.5), fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
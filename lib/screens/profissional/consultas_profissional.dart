import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/utils/time_utils.dart';
import 'package:plenonexo/utils/i18n_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:plenonexo/services/appointment_service.dart';
import 'package:plenonexo/services/user_service.dart';
import '../../utils/app_theme.dart';

class ConsultasProfissional extends StatefulWidget {
  const ConsultasProfissional({super.key});

  @override
  State<ConsultasProfissional> createState() => _ConsultasProfissionalState();
}

class _ConsultasProfissionalState extends State<ConsultasProfissional> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppointmentService _appointmentService = AppointmentService();
  final UserService _userService = UserService();
  
  String _filtroStatus = 'Todas';
  bool _mostrarApenasHoje = false;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Minhas Consultas')),
        body: const Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: Text(
          'Minhas Consultas',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _mostrarFiltros,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _appointmentService.getProfessionalAppointmentsSimple(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma consulta encontrada',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var appointments = snapshot.data!;
                
                // Aplicar filtros
                if (_filtroStatus != 'Todas') {
                  appointments = appointments.where((appointment) {
                    return appointment.status.toLowerCase() == _filtroStatus.toLowerCase();
                  }).toList();
                }
                
                if (_mostrarApenasHoje) {
                  final now = DateTime.now();
                  appointments = appointments.where((appointment) {
                    final appointmentDate = appointment.dateTime;
                    return appointmentDate.year == now.year && 
                           appointmentDate.month == now.month && 
                           appointmentDate.day == now.day;
                  }).toList();
                }

                // Ordenar por data
                appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return _buildAppointmentCard(appointment);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _filtroStatus,
              isExpanded: true,
              underline: Container(),
              items: ['Todas', 'scheduled', 'cancelled', 'completed', 'missed']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_translateStatus(value)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _filtroStatus = newValue!;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Checkbox(
                  value: _mostrarApenasHoje,
                  onChanged: (bool? value) {
                    setState(() {
                      _mostrarApenasHoje = value!;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Apenas hoje',
                    style: GoogleFonts.poppins(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final now = DateTime.now();
    final isPast = appointment.dateTime.isBefore(now);
    final status = _getStatusText(appointment, isPast);
    final statusColor = _getStatusColor(appointment.status, isPast);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(
                _getStatusIcon(appointment.status, isPast),
                color: statusColor,
              ),
            ),
            title: Text(
              appointment.patientName ?? 'Paciente não identificado',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                BrazilTime.formatDateTime(appointment.dateTime),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.subject,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _translateStatus(status),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuSelection(value, appointment),
              itemBuilder: (BuildContext context) {
                final menuItems = <PopupMenuEntry<String>>[];
                
                // Cancelar consulta (profissional e paciente)
                if (appointment.status == 'scheduled') {
                  menuItems.add(
                    const PopupMenuItem<String>(
                      value: 'confirm',
                      child: Text('Confirmar Consulta'),
                    ),
                  );
                  menuItems.add(
                    const PopupMenuItem<String>(
                      value: 'cancel',
                      child: Text('Cancelar Consulta'),
                    ),
                  );
                }
                
                if (menuItems.isEmpty) {
                  menuItems.add(
                    const PopupMenuItem<String>(
                      value: 'no_action',
                      child: Text('Sem ações disponíveis'),
                      enabled: false,
                    ),
                  );
                }
                
                return menuItems;
              },
            ),
          ),
          if (appointment.status == 'cancelled' && appointment.cancellationReason != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[400], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Consulta cancelada: ${I18nUtils.localizeCancellationReason(appointment.cancellationReason!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filtrar Consultas',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Conteúdo do filtro aqui
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(AppointmentModel appointment, bool isPast) {
    if (appointment.status == 'scheduled') {
      if (isPast) {
        return 'missed'; // Perdido
      } else {
        return 'scheduled'; // Agendada
      }
    }
    return appointment.status;
  }

  Color _getStatusColor(String status, bool isPast) {
    if (status == 'scheduled' && isPast) {
      return Colors.orange; // Perdido
    }
    
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'missed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status, bool isPast) {
    if (status == 'scheduled' && isPast) {
      return Icons.event_busy;
    }
    
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Icons.event_available;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'missed':
        return Icons.event_busy;
      default:
        return Icons.help_outline;
    }
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Agendada';
      case 'completed':
        return 'Realizada';
      case 'cancelled':
        return 'Cancelada';
      case 'missed':
        return 'Perdida';
      case 'todas':
        return 'Todas';
      default:
        return status;
    }
  }

  void _handleMenuSelection(String value, AppointmentModel appointment) async {
    switch (value) {
      case 'mark_completed':
        await _marcarComoRealizada(appointment);
        break;
      case 'confirm':
        await _tryConfirmAppointment(appointment);
        break;
      case 'cancel':
        await _cancelarConsulta(appointment);
        break;
    }
  }

  Future<void> _marcarComoRealizada(AppointmentModel appointment) async {
    try {
      await _appointmentService.updateAppointmentStatus(appointment.id, 'completed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consulta marcada como realizada!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao marcar consulta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _tryConfirmAppointment(AppointmentModel appointment) async {
    try {
      final scheduled = appointment.dateTime;
      final now = DateTime.now();
      final isSameDay = now.year == scheduled.year &&
          now.month == scheduled.month &&
          now.day == scheduled.day;
      final isSameHour = now.hour == scheduled.hour;

      if (!isSameDay || !isSameHour) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ainda não é possível confirmar: a consulta só pode ser confirmada no dia e horário agendados.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await _appointmentService.updateAppointmentStatus(appointment.id, 'completed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consulta confirmada como realizada.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao confirmar consulta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelarConsulta(AppointmentModel appointment) async {
    final motivo = await _mostrarDialogoCancelamento();
    if (motivo != null && motivo.isNotEmpty) {
      try {
        await _appointmentService.cancelAppointment(appointment.id, 'Cancelado pelo profissional: $motivo');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consulta cancelada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar consulta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _mostrarDialogoCancelamento() async {
    final motivoController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancelar Consulta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Por favor, informe o motivo do cancelamento:'),
              const SizedBox(height: 16),
              TextField(
                controller: motivoController,
                decoration: InputDecoration(
                  hintText: 'Digite o motivo aqui...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Voltar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(motivoController.text),
              child: Text('Confirmar Cancelamento'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}
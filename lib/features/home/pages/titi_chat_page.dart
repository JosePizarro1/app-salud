import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final bool isTyping;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isTyping = false,
  });
}

class TitiChatPage extends StatefulWidget {
  const TitiChatPage({super.key});

  @override
  State<TitiChatPage> createState() => _TitiChatPageState();
}

class _TitiChatPageState extends State<TitiChatPage> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // Chat state tracking
  int _currentStep = 0; // 0: Welcome, 1: Detection, 2: Intensity, 3: Duration, 4: Cause, 5: Immediate Need, 6: Recommendation
  bool _isTitiTyping = false;

  // Selected values to derive correct department
  String? _selectedFeeling;
  String? _selectedIntensity;
  String? _selectedDuration;
  String? _selectedCause;
  String? _selectedNeed;

  @override
  void initState() {
    super.initState();
    // Add Titi's welcome message immediately
    _messages.add(
      ChatMessage(
        text: '¡Hola! Soy Titi 🐱 Estoy aquí para escucharte y ayudarte. Para poder orientarte mejor, te haré algunas preguntas rápidas, ¿te parece?',
        isUser: false,
        time: _getCurrentTime(),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Helper to handle native call
  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await launchUrl(launchUri)) {
        debugPrint('Llamando a $phoneNumber exitosamente');
      } else {
        throw 'No se pudo abrir el dialer.';
      }
    } catch (e) {
      _showErrorSnackBar('No se pudo realizar la llamada. Teléfono: $phoneNumber');
    }
  }

  // Helper to handle email launch
  Future<void> _sendEmail(String email, String subject, String body) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    try {
      if (await launchUrl(emailLaunchUri)) {
        debugPrint('Enviando correo a $email');
      } else {
        throw 'No se pudo abrir cliente de correo.';
      }
    } catch (e) {
      _showErrorSnackBar('No se pudo abrir el cliente de correo. Email: $email');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE57373),
      ),
    );
  }

  void _onUserAcceptStart() async {
    // Add user accept message
    setState(() {
      _messages.add(
        ChatMessage(
          text: 'Sí, está bien',
          isUser: true,
          time: _getCurrentTime(),
        ),
      );
      _currentStep = 1;
      _isTitiTyping = true;
    });
    _scrollToBottom();

    // Simulated thinking delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _isTitiTyping = false;
        _messages.add(
          ChatMessage(
            text: '1. ¿Cómo te sientes en este momento?',
            isUser: false,
            time: _getCurrentTime(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _onOptionSelected(String value) async {
    // Add user response message
    setState(() {
      _messages.add(
        ChatMessage(
          text: value,
          isUser: true,
          time: _getCurrentTime(),
        ),
      );
      _isTitiTyping = true;
    });
    _scrollToBottom();

    // Store value based on current step and progress
    if (_currentStep == 1) {
      _selectedFeeling = value;
    } else if (_currentStep == 2) {
      _selectedIntensity = value;
    } else if (_currentStep == 3) {
      _selectedDuration = value;
    } else if (_currentStep == 4) {
      _selectedCause = value;
    } else if (_currentStep == 5) {
      _selectedNeed = value;
    }

    // Simulated thinking delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _isTitiTyping = false;
      _currentStep++;

      if (_currentStep == 2) {
        _messages.add(
          ChatMessage(
            text: '2. ¿Qué tan intenso es lo que estás sintiendo?',
            isUser: false,
            time: _getCurrentTime(),
          ),
        );
      } else if (_currentStep == 3) {
        _messages.add(
          ChatMessage(
            text: '3. ¿Desde cuándo te sientes así?',
            isUser: false,
            time: _getCurrentTime(),
          ),
        );
      } else if (_currentStep == 4) {
        _messages.add(
          ChatMessage(
            text: '4. ¿Qué crees que está provocando esto?',
            isUser: false,
            time: _getCurrentTime(),
          ),
        );
      } else if (_currentStep == 5) {
        _messages.add(
          ChatMessage(
            text: '5. ¿Qué necesitas ahora mismo?',
            isUser: false,
            time: _getCurrentTime(),
          ),
        );
      } else if (_currentStep == 6) {
        _messages.add(
          ChatMessage(
            text: 'Gracias por confiar en mí 💜 Estoy analizando lo que me contaste para darte la mejor recomendación.',
            isUser: false,
            time: _getCurrentTime(),
          ),
        );
        _triggerFinalRecommendation();
      }
    });
    _scrollToBottom();
  }

  void _triggerFinalRecommendation() async {
    setState(() {
      _isTitiTyping = true;
    });
    _scrollToBottom();

    // Deeper thinking delay for full emotional analysis simulation
    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      setState(() {
        _isTitiTyping = false;
      });
      _scrollToBottom();
    }
  }

  // High-fidelity dynamic recommendation builder based on custom answers
  Widget _buildRecommendationCard() {
    // Derivation Logic
    String derivedArea = 'Dirección de Bienestar Universitario (DBUN)';
    String email = 'dbun@unjbg.edu.pe';
    String explanationText = 'Lo que me cuentas indica que buscas orientación y acompañamiento general para tu bienestar.';

    bool isHighRisk = _selectedIntensity == 'Muy alto / No puedo manejarlo' || _selectedFeeling == '😟 Muy abrumado';
    bool isAcademic = _selectedCause == 'Carga académica' || _selectedCause == 'Exámenes / notas' || _selectedFeeling == '🤯 Estresado por estudios';
    bool isAnxietyOrSad = _selectedFeeling == '😰 Ansioso o preocupado' || _selectedFeeling == '😔 Triste o desmotivado' || _selectedNeed == 'Atención psicológica';
    bool isConflict = _selectedCause == 'Conflictos sociales' || _selectedCause == 'Problemas familiares';

    // Incorporate selected duration to fine-tune explanation text
    String durationDetails = '';
    if (_selectedDuration != null) {
      durationDetails = ' que experimentas ${_selectedDuration!.toLowerCase()}';
    }

    if (isHighRisk) {
      derivedArea = 'Dirección de Bienestar Universitario (DBUN)';
      email = 'dbun@unjbg.edu.pe';
      explanationText = 'Lo que me cuentas indica que estás atravesando una situación de intensidad emocional muy alta$durationDetails. Te recomendamos ponerte en contacto de inmediato.';
    } else if (isAcademic) {
      derivedArea = 'Unidad de Tutoría (UTU)';
      email = 'utu@unjbg.edu.pe';
      explanationText = 'Lo que me cuentas indica que podrías estar atravesando una situación de estrés académico o presión por exámenes$durationDetails.';
    } else if (isAnxietyOrSad) {
      derivedArea = 'Psicopedagogía y Psicología';
      email = 'psico@unjbg.edu.pe';
      explanationText = 'Lo que me cuentas indica que podrías estar atravesando una situación de ansiedad moderada o tristeza persistente$durationDetails.';
    } else if (isConflict) {
      derivedArea = 'Defensoría Universitaria';
      email = 'defu@unjbg.edu.pe';
      explanationText = 'Lo que me cuentas indica que los problemas familiares o conflictos sociales$durationDetails están impactando tu bienestar.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Recommended main badge card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF7EE), // soft green pastel matching screenshot
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF81C784).withValues(alpha: 0.5), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF28AF52),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      explanationText,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B5E20),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Te recomiendo hablar con un profesional especializado que puede acompañarte.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A5D4E),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Recommended Area white container inside
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F4FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: Color(0xFF3B60B3),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Área recomendada:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            derivedArea,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3B60B3),
                            ),
                          ),
                          Text(
                            'Profesionales listos para escucharte y apoyarte.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action options at the bottom
        Text(
          '¿Qué te gustaría hacer ahora?',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3B60B3),
          ),
        ),
        const SizedBox(height: 12),

        // Action 1: Hablar con profesional
        _buildActionOption(
          icon: Icons.chat_bubble_rounded,
          iconColor: const Color(0xFF3B60B3),
          bgColor: const Color(0xFFF2F5FF),
          title: 'Quiero hablar con un profesional',
          subtitle: 'Te conectaremos con el área indicada',
          onTap: () {
            _sendEmail(
              email,
              'Apoyo Emocional - Consulta de Estudiante',
              'Estimado/a responsable,\n\nEscribo a través del botón de emergencia de la aplicación de salud de Titi. Me gustaría solicitar orientación y conversar con un profesional sobre mi bienestar emocional.\n\nAtentamente,\n[Nombre del Estudiante]',
            );
          },
        ),
        const SizedBox(height: 10),

        // Action 2: Ver información de contacto
        _buildActionOption(
          icon: Icons.phone_rounded,
          iconColor: const Color(0xFF28AF52),
          bgColor: const Color(0xFFEBF7EE),
          title: 'Ver información de contacto',
          subtitle: 'Correos, anexos y horarios de atención',
          onTap: _showContactListBottomSheet,
        ),
        const SizedBox(height: 10),

        // Action 3: Pausa activa
        _buildActionOption(
          icon: Icons.spa_rounded,
          iconColor: const Color(0xFFFF9800),
          bgColor: const Color(0xFFFFF7ED),
          title: 'Quiero hacer una pausa activa',
          subtitle: 'Ejercicios de respiración y relajación',
          onTap: () {
            context.push('/active_pause');
          },
        ),
      ],
    );
  }

  Widget _buildActionOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Beautiful contact sheet with all academic support departments
  void _showContactListBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet drag indicator
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.contact_phone_rounded,
                    color: Color(0xFF3B60B3),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Directorio de Soporte',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B60B3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Puedes comunicarte directamente con cada oficina universitaria para recibir asistencia personalizada.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Contact item 1: DBUN
              _buildContactRow(
                title: 'Dirección de Bienestar Universitario',
                responsable: 'Silvia Carmen Risco Aliaga',
                email: 'dbun@unjbg.edu.pe',
                anexo: '3017',
              ),
              const Divider(height: 24),

              // Contact item 2: Psicología
              _buildContactRow(
                title: 'Psicopedagogía y Psicología',
                responsable: 'Liliana Angélica De La Macarena Rivas Hidalgo',
                email: 'psico@unjbg.edu.pe',
                anexo: '3020',
              ),
              const Divider(height: 24),

              // Contact item 3: Tutoría
              _buildContactRow(
                title: 'Unidad de Tutoría',
                responsable: 'Carmen Graciela Consuelo Salleres Sanchez',
                email: 'utu@unjbg.edu.pe',
                anexo: 'Central',
              ),
              const Divider(height: 24),

              // Contact item 4: Defensoría
              _buildContactRow(
                title: 'Defensoría Universitaria',
                responsable: 'Victoria del Socorro Martos Montoya',
                email: 'defu@unjbg.edu.pe',
                anexo: '1009',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactRow({
    required String title,
    required String responsable,
    required String email,
    required String anexo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3B60B3),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Responsable: $responsable',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.phone_in_talk_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              'Anexo: $anexo',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Call button
            ElevatedButton.icon(
              onPressed: () {
                _makeCall('052583000'); // Base university number as requested
              },
              icon: const Icon(Icons.phone, size: 14, color: Colors.white),
              label: Text(
                'Llamar',
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28AF52),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Email button
            OutlinedButton.icon(
              onPressed: () {
                _sendEmail(
                  email,
                  'Solicitud de Apoyo - Estudiante UNJBG',
                  'Estimada $responsable,\n\nEscribo desde la aplicación móvil de soporte de bienestar emocional para solicitar apoyo u orientación.\n\nAtentamente,\n[Nombre del Estudiante]',
                );
              },
              icon: const Icon(Icons.mail_outline, size: 14, color: Color(0xFF3B60B3)),
              label: Text(
                'Enviar Correo',
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B60B3),
                side: const BorderSide(color: Color(0xFF3B60B3), width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // permanent university call modal trigger
  void _showGeneralUniversityCallDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'BaseCall',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEBF7EE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_in_talk, color: Color(0xFF28AF52)),
                ),
                const SizedBox(width: 12),
                Text(
                  'Llamar a la UNJBG',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B60B3),
                  ),
                ),
              ],
            ),
            content: Text(
              '¿Deseas realizar una llamada telefónica directa al número base de la Universidad Nacional Jorge Basadre Grohmann? \n\n📞 Central: (052) 583000',
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _makeCall('052583000'); // calls (052) 583000
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28AF52),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text(
                  'Llamar ahora',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB), // Modern light pastel background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4C7CC2), Color(0xFF3B60B3)], // beautiful calming blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  // Round Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/gato1.png'), // round avatar of Titi
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Titi',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Estoy aquí para escucharte 💜',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ALWAYS ACCESSIBLE Call Button inside Appbar
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
                      tooltip: 'Llamar Central UNJBG',
                      onPressed: _showGeneralUniversityCallDialog,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Dynamic scrolling message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Titi Typing Indicator
          if (_isTitiTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/gato1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F0F5),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: _buildTypingDotsAnimation(),
                  ),
                ],
              ),
            ),

          // Dynamic Interaction Panel at the bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _buildInteractionContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    Widget bubble;
    if (msg.isUser) {
      // User Message Bubble (Right alignment)
      bubble = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCF8C6), // WhatsApp user bubble green
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(0), // sharp tail
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      msg.text,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF303030), // Dark text for WhatsApp style
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    msg.time,
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Color(0xFF34B7F1), // WhatsApp blue ticks
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Titi's Message Bubble (Left alignment)
      bubble = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/gato1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white, // WhatsApp Titi bubble white
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(0), // sharp tail
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              msg.text,
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF303030),
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            msg.time,
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                          ),
                        ],
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
    
    // Wrap with FadeInUp for smooth entry
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      from: 15,
      child: bubble,
    );
  }

  // Bouncing typing animation with dots
  Widget _buildTypingDotsAnimation() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Pulse(
          infinite: true,
          delay: Duration(milliseconds: index * 200),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF4C7CC2),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }

  // Dynamic layout switcher based on active step of Chat
  Widget _buildInteractionContent() {
    if (_currentStep == 0) {
      // Intro notice & accept button
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Information notice bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: Color(0xFF4C7CC2), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Todo lo que me cuentes es confidencial y solo se usa para ayudarte.',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3B60B3),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _onUserAcceptStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C7CC2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Sí, está bien',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (_currentStep >= 1 && _currentStep <= 5) {
      // Connective progress bar & active question selectors
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressBarIndicator(),
          const SizedBox(height: 20),
          _buildQuestionSelectors(),
        ],
      );
    } else {
      // Final Recommendation layout
      return _buildRecommendationCard();
    }
  }

  // Connective Progress bar showing steps 1 to 5 dynamically
  Widget _buildProgressBarIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(9, (index) {
        if (index % 2 == 0) {
          // Circle node
          final stepNum = (index ~/ 2) + 1;
          final isActive = stepNum == _currentStep;
          final isCompleted = stepNum < _currentStep;

          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF4C7CC2)
                  : (isCompleted ? const Color(0xFFD0DEF8) : const Color(0xFFF1F0F5)),
              border: isActive
                  ? Border.all(color: const Color(0xFFD0DEF8), width: 3)
                  : null,
            ),
            child: Center(
              child: Text(
                '$stepNum',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? Colors.white
                      : (isCompleted ? const Color(0xFF4C7CC2) : Colors.grey[500]),
                ),
              ),
            ),
          );
        } else {
          // Connecting line
          final beforeStep = (index ~/ 2) + 1;
          final isCompleted = beforeStep < _currentStep;

          return Expanded(
            child: Container(
              height: 3,
              color: isCompleted ? const Color(0xFFD0DEF8) : const Color(0xFFF1F0F5),
            ),
          );
        }
      }),
    );
  }

  // Question option lists based on active step
  Widget _buildQuestionSelectors() {
    if (_currentStep == 1) {
      return _buildOptionSelectorCard([
        '😟 Muy abrumado',
        '😰 Ansioso o preocupado',
        '😔 Triste o desmotivado',
        '😫 Confundido o bloqueado',
        '🤯 Estresado por estudios',
        '🙂 Solo necesito orientación',
      ]);
    } else if (_currentStep == 2) {
      return _buildOptionSelectorCard([
        'Leve',
        'Moderado',
        'Alto',
        'Muy alto / No puedo manejarlo',
      ]);
    } else if (_currentStep == 3) {
      return _buildOptionSelectorCard([
        'Desde hoy',
        'Hace algunos días',
        'Hace semanas',
        'Hace meses',
      ]);
    } else if (_currentStep == 4) {
      return _buildOptionSelectorCard([
        'Carga académica',
        'Exámenes / notas',
        'Problemas familiares',
        'Problemas personales/emocionales',
        'Conflictos sociales',
        'Problemas económicos',
        'No estoy seguro/a',
      ]);
    } else if (_currentStep == 5) {
      return _buildOptionSelectorCard([
        'Relajarme',
        'Hablar con alguien',
        'Consejos prácticos',
        'Atención psicológica',
        'Información universitaria',
      ]);
    }
    return const SizedBox.shrink();
  }

  Widget _buildOptionSelectorCard(List<String> options) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35, // Prevent overflowing screen
      ),
      child: RawScrollbar(
        thumbColor: Colors.grey[300],
        radius: const Radius.circular(10),
        thickness: 4,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(right: 8.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: options.map((opt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onOptionSelected(opt),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

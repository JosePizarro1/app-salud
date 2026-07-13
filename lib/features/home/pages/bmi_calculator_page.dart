import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/services/sfx_manager.dart';
import '../widgets/module_header.dart';

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  int _years = 15;
  int _months = 0;
  String _gender = 'M'; // 'M' for Masculino, 'F' for Femenino
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  double? _bmiResult;
  String _bmiClassification = '';
  String _titiAdvice = '';
  Color _resultColor = Colors.green;
  bool _needsNutritionist = false;
  bool _showFloatingTip = false;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFloatingTip = true;
        });
        SfxManager().playNotiSound();
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // Dismiss keyboard
    SfxManager().playClick();

    final double weight = double.tryParse(_weightController.text) ?? 0;
    final double heightCm = double.tryParse(_heightController.text) ?? 0;

    if (weight <= 0 || heightCm <= 0) return;

    final double heightM = heightCm / 100;
    final double bmi = weight / (heightM * heightM);

    setState(() {
      _bmiResult = bmi;
      _classifyBmi(bmi);
    });

    // Auto-scroll down to show the result
    Future.delayed(const Duration(milliseconds: 350), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _classifyBmi(double bmi) {
    bool isFemale = _gender == 'F';

    if (_years >= 19) {
      // Adult classification (>= 19 years old)
      if (bmi >= 40.0) {
        _bmiClassification = 'Obesidad grado III o mórbida';
        _resultColor = const Color(0xFF8B0000); // Deep red
        _titiAdvice = 'Tu IMC indica obesidad mórbida. ¡Es vital cuidar tu salud!';
        _needsNutritionist = true;
      } else if (bmi >= 35.0) {
        _bmiClassification = 'Obesidad grado II o grave';
        _resultColor = const Color(0xFFC70039); // Red
        _titiAdvice = 'Tu IMC indica obesidad grave. Tu bienestar es lo más importante.';
        _needsNutritionist = true;
      } else if (bmi >= 30.0) {
        _bmiClassification = 'Obesidad grado I o moderada';
        _resultColor = const Color(0xFFFF5733); // Light red/orange
        _titiAdvice = 'Tu IMC indica obesidad moderada. Pequeños cambios diarios harán una gran diferencia.';
        _needsNutritionist = true;
      } else if (bmi >= 25.0) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFFF8C00); // Dark Orange
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Es una gran oportunidad para mejorar tus hábitos!';
        _needsNutritionist = true;
      } else if (bmi >= 18.5) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50); // Green
        _titiAdvice = '¡Excelente! Tu peso está en un rango saludable. ¡Seguí así con tu buena alimentación!';
        _needsNutritionist = false;
      } else if (bmi >= 17.0) {
        _bmiClassification = 'Delgadez aceptable';
        _resultColor = const Color(0xFFFFC107); // Yellow/Amber
        _titiAdvice = 'Tu peso es un poco bajo. Consumir alimentos ricos en energía saludable te ayudará.';
        _needsNutritionist = true;
      } else if (bmi >= 16.0) {
        _bmiClassification = 'Delgadez moderada';
        _resultColor = const Color(0xFFFF9800); // Orange
        _titiAdvice = 'Tu peso se encuentra en el rango de delgadez moderada. ¡Nutrirte bien es clave!';
        _needsNutritionist = true;
      } else {
        _bmiClassification = 'Delgadez severa';
        _resultColor = const Color(0xFFF44336); // Red
        _titiAdvice = 'Tu peso es muy bajo. Es importante que le aportes más nutrientes a tu cuerpo.';
        _needsNutritionist = true;
      }
    } else {
      // Adolescent classification (15 - 18 years old based on OMS 2007)
      if (isFemale) {
        _classifyFemaleAdolescent(bmi);
      } else {
        _classifyMaleAdolescent(bmi);
      }
    }
  }

  void _classifyFemaleAdolescent(double bmi) {
    _needsNutritionist = true;
    
    // Determine the age bracket row
    int ageMonthsTotal = (_years * 12) + _months;
    
    // 15:0 row (15 years 0 months to 15 years 5 months) -> ageMonthsTotal < 186
    if (ageMonthsTotal < 186) {
      if (bmi >= 28.2) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad para tu edad. ¡Cuidemos tu salud juntos!';
      } else if (bmi >= 23.5) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso para tu edad. ¡Sumá más frutas y verduras a tu día!';
      } else if (bmi >= 17.8) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Genial! Tu peso está en el rango normal para tu edad. ¡Seguí con esa energía!';
        _needsNutritionist = false;
      } else if (bmi >= 15.9) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso es un poco bajo. ¡Es importante comer alimentos nutritivos!';
      } else if (bmi >= 14.4) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. ¡Tu cuerpo necesita más energía!';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso es muy bajo para tu edad. Necesitamos fortalecer tu cuerpo.';
      }
    } 
    // 15:6 row -> ageMonthsTotal < 192
    else if (ageMonthsTotal < 192) {
      if (bmi >= 28.6) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad para tu edad. ¡Es un buen momento para actuar!';
      } else if (bmi >= 23.8) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Hacer actividad física y comer sano te ayudará!';
      } else if (bmi >= 18.0) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Excelente! Estás en un peso saludable. ¡Disfrutá tu vitalidad!';
        _needsNutritionist = false;
      } else if (bmi >= 16.0) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso está un poquito bajo. ¡Dale más nutrientes a tu día!';
      } else if (bmi >= 14.5) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. ¡Consumir proteínas y cereales te hará bien!';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso es muy bajo. Es clave revisar tu alimentación diaria.';
      }
    } 
    // 16:0 row -> ageMonthsTotal < 198
    else if (ageMonthsTotal < 198) {
      if (bmi >= 28.9) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Vamos a cuidar tu bienestar!';
      } else if (bmi >= 24.1) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Elegir snacks saludables te ayudará!';
      } else if (bmi >= 18.2) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Tu peso es normal y saludable! Seguí alimentándote de forma variada.';
        _needsNutritionist = false;
      } else if (bmi >= 16.2) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso es un poco bajo. ¡Es importante comer a tus horas!';
      } else if (bmi >= 14.6) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. ¡Tu cuerpo necesita más combustible!';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso está muy por debajo de lo ideal. Cuidemos tu salud.';
      }
    } 
    // 16:6 row -> ageMonthsTotal < 204
    else if (ageMonthsTotal < 204) {
      if (bmi >= 29.1) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Cuidar tu cuerpo es un gran acto de amor propio!';
      } else if (bmi >= 24.3) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Intentá tomar más agua y moverte más!';
      } else if (bmi >= 18.3) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Buenísimo! Tu peso es completamente normal. ¡Tenés una energía genial!';
        _needsNutritionist = false;
      } else if (bmi >= 16.3) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso es levemente bajo. ¡Intentá incluir porciones más completas!';
      } else if (bmi >= 14.7) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. ¡Consumir súper alimentos te ayudará!';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso es muy bajo. Es vital que fortalezcas tu alimentación.';
      }
    } 
    // 17:0 row -> ageMonthsTotal < 210
    else if (ageMonthsTotal < 210) {
      if (bmi >= 29.3) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Hagamos pequeños cambios hoy!';
      } else if (bmi >= 24.5) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Moderá las porciones y comé más sano!';
      } else if (bmi >= 18.4) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Fantástico! Estás en tu peso ideal para tu edad. ¡Seguí cuidándote!';
        _needsNutritionist = false;
      } else if (bmi >= 16.4) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso está un poco bajo. ¡Comer frutos secos y frutas te dará energía!';
      } else if (bmi >= 14.7) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. Tu cuerpo necesita más energía.';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso es muy bajo. Tu salud es nuestra prioridad.';
      }
    } 
    // 17:6 row -> ageMonthsTotal < 216
    else if (ageMonthsTotal < 216) {
      if (bmi >= 29.4) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Dale a tu cuerpo nutrientes de calidad!';
      } else if (bmi >= 24.6) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Mejorar tu alimentación mejorará tu día!';
      } else if (bmi >= 18.5) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Felicitaciones! Tu peso está en el rango normal. ¡Seguí así!';
        _needsNutritionist = false;
      } else if (bmi >= 16.4) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso es ligeramente bajo. ¡Nutrirte bien te mantendrá fuerte!';
      } else if (bmi >= 14.7) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. Es importante que comas más calorías sanas.';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso está muy bajo. Prestemos atención a lo que tu cuerpo necesita.';
      }
    } 
    // 18:0 row -> >= 18 years, 0 months (and less than 19 years)
    else {
      if (bmi >= 29.5) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Cuidemos tu cuerpo y tu salud!';
      } else if (bmi >= 24.8) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Sumar agua y comida real te ayudará mucho!';
      } else if (bmi >= 18.6) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Excelente! Estás en un peso ideal para tu edad. ¡Tenés un balance espectacular!';
        _needsNutritionist = false;
      } else if (bmi >= 16.4) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso está un poco bajo. ¡Es fundamental que no te saltes comidas!';
      } else if (bmi >= 14.7) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. ¡Tu cuerpo necesita recuperar fuerza!';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso es muy bajo. Cuidar tu nutrición is clave en esta etapa.';
      }
    }
  }

  void _classifyMaleAdolescent(double bmi) {
    _needsNutritionist = true;
    
    // Determine the age bracket row
    int ageMonthsTotal = (_years * 12) + _months;
    
    // 15:0 row (15 years 0 months to 15 years 5 months)
    if (ageMonthsTotal < 186) {
      if (bmi >= 27.0) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad para tu edad. ¡Es momento de cuidar tu cuerpo!';
      } else if (bmi >= 22.7) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Más actividad física y verduras te ayudarán!';
      } else if (bmi >= 17.6) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Excelente! Estás en el rango normal para tu edad. ¡Seguí con esa energía!';
        _needsNutritionist = false;
      } else if (bmi >= 16.0) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso es un poco bajo. ¡Necesitás incluir más energía saludable!';
      } else if (bmi >= 14.7) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. ¡Alimentate bien para estar fuerte!';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso es muy bajo para tu edad. Tu salud es nuestra prioridad.';
      }
    } 
    // 15:6 row
    else if (ageMonthsTotal < 192) {
      if (bmi >= 27.4) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Hagamos pequeños cambios hoy!';
      } else if (bmi >= 23.1) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Elegir mejores alimentos te ayudará!';
      } else if (bmi >= 18.0) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Genial! Tu peso está perfecto para tu edad. ¡Seguí cuidándote!';
        _needsNutritionist = false;
      } else if (bmi >= 16.3) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso está ligeramente bajo. ¡Es importante comer de forma balanceada!';
      } else if (bmi >= 14.9) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. Tu cuerpo necesita más combustible.';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso es muy bajo. Cuidar tu alimentación te dará más fuerza.';
      }
    } 
    // 16:0 row
    else if (ageMonthsTotal < 198) {
      if (bmi >= 27.9) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Cuidar tu cuerpo es una prioridad!';
      } else if (bmi >= 23.5) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Reducí procesados y tomá más agua!';
      } else if (bmi >= 18.2) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Buenísimo! Estás en tu peso ideal. ¡Tenés un balance espectacular!';
        _needsNutritionist = false;
      } else if (bmi >= 16.5) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso está un poquito bajo. ¡Alimentate bien para no perder energía!';
      } else if (bmi >= 15.1) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. ¡Tu cuerpo necesita ganar fuerza!';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso es muy bajo. Prestemos atención a lo que tu cuerpo necesita.';
      }
    } 
    // 16:6 row
    else if (ageMonthsTotal < 204) {
      if (bmi >= 28.3) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Cuidemos tu salud juntos!';
      } else if (bmi >= 23.9) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Sumá frutas y hacé más deporte!';
      } else if (bmi >= 18.5) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Excelente! Tu peso es completamente normal para tu edad. ¡Seguí así!';
        _needsNutritionist = false;
      } else if (bmi >= 16.7) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso es ligeramente bajo. ¡Es importante comer lo suficiente!';
      } else if (bmi >= 15.3) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. Tu alimentación debe ser más completa.';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso está muy por debajo de lo ideal. Tu bienestar es clave.';
      }
    } 
    // 17:0 row
    else if (ageMonthsTotal < 210) {
      if (bmi >= 28.6) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad para tu edad. ¡Tu salud es lo primero!';
      } else if (bmi >= 24.3) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Intentá evitar la comida chatarra!';
      } else if (bmi >= 18.8) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Felicitaciones! Tu peso está en el rango saludable. ¡Seguí con esos hábitos!';
        _needsNutritionist = false;
      } else if (bmi >= 16.9) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso está un poco bajo. ¡Es fundamental no saltearse el desayuno!';
      } else if (bmi >= 15.4) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. Necesitamos fortalecer tu cuerpo.';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso está muy bajo. Busquemos mejorar tu nutrición diaria.';
      }
    } 
    // 17:6 row
    else if (ageMonthsTotal < 216) {
      if (bmi >= 29.0) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Hagamos mejores elecciones cada día!';
      } else if (bmi >= 24.6) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Cuidar tu porción te hará sentir mejor!';
      } else if (bmi >= 19.0) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Excelente! Estás en un peso ideal para tu edad. ¡Tenés un balance espectacular!';
        _needsNutritionist = false;
      } else if (bmi >= 17.1) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso está un poquito bajo. ¡Sumá calorías nutritivas a tu dieta!';
      } else if (bmi >= 15.6) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. ¡Tu cuerpo necesita más energía!';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso es bastante bajo. Cuidar tu alimentación te dará más vitalidad.';
      }
    } 
    // 18:0 row
    else {
      if (bmi >= 29.2) {
        _bmiClassification = 'Obesidad';
        _resultColor = const Color(0xFF9083ED);
        _titiAdvice = 'Tu IMC indica obesidad. ¡Cuidemos tu cuerpo y tu salud!';
      } else if (bmi >= 24.9) {
        _bmiClassification = 'Sobrepeso';
        _resultColor = const Color(0xFFB1AFFF);
        _titiAdvice = 'Tu IMC indica sobrepeso. ¡Es una gran oportunidad para mejorar tus hábitos!';
      } else if (bmi >= 19.2) {
        _bmiClassification = 'Normal';
        _resultColor = const Color(0xFF4CAF50);
        _titiAdvice = '¡Felicidades! Estás en tu peso ideal. ¡Tenés un balance espectacular!';
        _needsNutritionist = false;
      } else if (bmi >= 17.3) {
        _bmiClassification = 'Desnutrición leve';
        _resultColor = const Color(0xFFFFC107);
        _titiAdvice = 'Tu peso está un poco bajo. ¡Es importante comer alimentos completos!';
      } else if (bmi >= 15.7) {
        _bmiClassification = 'Desnutrición moderada';
        _resultColor = const Color(0xFFFF9800);
        _titiAdvice = 'Tu peso indica desnutrición moderada. Tu cuerpo necesita recuperar combustible.';
      } else {
        _bmiClassification = 'Desnutrición severa';
        _resultColor = const Color(0xFFF44336);
        _titiAdvice = 'Tu peso está muy bajo. Es vital fortalecer tu alimentación.';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4D7), // Peach color requested
      body: SafeArea(
        child: Stack(
          children: [
            // Soft background food & health decorations
            Positioned(
              bottom: -20,
              left: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(15 / 360),
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 150,
                  color: Colors.black.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -30,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(-20 / 360),
                child: Icon(
                  Icons.apple_rounded,
                  size: 140,
                  color: Colors.black.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(45 / 360),
                child: Icon(
                  Icons.emoji_food_beverage_rounded,
                  size: 110,
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
            ),

            // Main Content Scroll View (with top padding to avoid overlapping the header)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 120), // Leave space for the header
                child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // Screen Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFFFF8A71)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'CALCULAR IMC',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          const SizedBox(height: 10),

                          _buildInputCard(
                            title: 'Edad',
                            icon: Icons.calendar_today_rounded,
                            hint: _years < 19 ? 'Menor de 18: indica meses' : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Años (15 - 30)',
                                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.black12),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<int>(
                                                value: _years,
                                                isExpanded: true,
                                                items: List.generate(16, (i) => 15 + i)
                                                    .map((y) => DropdownMenuItem(
                                                          value: y,
                                                          child: Text('$y años', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                                        ))
                                                    .toList(),
                                                onChanged: (val) {
                                                  if (val != null) {
                                                    setState(() {
                                                      _years = val;
                                                      // Auto-reset months if 19 or older
                                                      if (_years >= 19) _months = 0;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Meses (0 - 11)',
                                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: _years >= 19 ? Colors.grey.shade100 : Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.black12),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<int>(
                                                value: _months,
                                                isExpanded: true,
                                                disabledHint: Text('0 meses', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black26)),
                                                items: _years >= 19
                                                    ? null
                                                    : List.generate(12, (i) => i)
                                                        .map((m) => DropdownMenuItem(
                                                              value: m,
                                                              child: Text('$m meses', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                                            ))
                                                        .toList(),
                                                onChanged: _years >= 19
                                                    ? null
                                                    : (val) {
                                                        if (val != null) {
                                                          setState(() => _months = val);
                                                        }
                                                      },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- SEXO CARD ---
                          _buildInputCard(
                            title: 'Sexo',
                            icon: Icons.people_outline_rounded,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildGenderSelector(
                                    genderValue: 'M',
                                    label: 'Masculino',
                                    avatarEmoji: '👦',
                                    selectedColor: const Color(0xFFE8F2FF),
                                    borderColor: const Color(0xFF1A73E8),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildGenderSelector(
                                    genderValue: 'F',
                                    label: 'Femenino',
                                    avatarEmoji: '👧',
                                    selectedColor: const Color(0xFFFFF0F5),
                                    borderColor: const Color(0xFFFF69B4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- PESO CARD ---
                          _buildInputCard(
                            title: 'Peso (kg)',
                            icon: Icons.scale_rounded,
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Ingresa tu peso en kilogramos',
                                hintStyle: GoogleFonts.outfit(color: Colors.black26),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.black12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa tu peso';
                                }
                                final parsed = double.tryParse(value);
                                if (parsed == null || parsed <= 0) {
                                  return 'Ingresa un peso válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- ESTATURA CARD ---
                          _buildInputCard(
                            title: 'Estatura (cm)',
                            icon: Icons.straighten_rounded,
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: 'Ingresa tu estatura en centímetros',
                                hintStyle: GoogleFonts.outfit(color: Colors.black26),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.black12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa tu estatura';
                                }
                                final parsed = int.tryParse(value);
                                if (parsed == null || parsed <= 0) {
                                  return 'Ingresa una estatura válida';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- CALCULATE BUTTON ---
                          GestureDetector(
                            onTap: _calculateBmi,
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8A71), // Orange/coral
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'CALCULAR MI IMC',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- RESULT BANNER / DIALOG CARD ---
                          _buildResultArea(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Header (Back & Home buttons)
            const ModuleHeader(showHome: true, showBack: true),

            // Floating tip overlay shown after 3 seconds
            if (_showFloatingTip)
              Positioned(
                top: 130, // Just below header buttons
                left: 20,
                right: 20,
                child: FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: GestureDetector(
                    onTap: () {
                      SfxManager().playClick();
                      setState(() {
                        _showFloatingTip = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB), // Soft warm yellow
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFEF3C7),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/healthy_eating/images/titi patita.webp',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.info_outline_rounded,
                              size: 32,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '¿Sabías qué?',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'El IMC relaciona tu peso con tu estatura para evaluar tu estado nutricional.',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF78350F),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xFFD97706),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({required String title, required IconData icon, String? hint, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if (hint != null) ...[
                const SizedBox(width: 6),
                const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFFD97706)),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    hint,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildGenderSelector({
    required String genderValue,
    required String label,
    required String avatarEmoji,
    required Color selectedColor,
    required Color borderColor,
  }) {
    bool isSelected = _gender == genderValue;

    return GestureDetector(
      onTap: () {
        SfxManager().playClick();
        setState(() {
          _gender = genderValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? borderColor : Colors.black12,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(avatarEmoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFF1E293B) : Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Custom Radio Circle
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? borderColor : Colors.black26,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: borderColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    if (_bmiResult == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
        ),
        child: Row(
          children: [
            // Stats icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF2ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bar_chart_rounded, size: 28, color: Color(0xFFFF8A71)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu resultado aparecerá aquí',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Completa todos los campos y presiona calcular.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          // BMI Result details
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _resultColor.withOpacity(0.3),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _resultColor.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'TU ÍNDICE DE MASA CORPORAL',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                // Calculated BMI value
                Text(
                  _bmiResult!.toStringAsFixed(1),
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: _resultColor,
                  ),
                ),
                const SizedBox(height: 6),
                // Classification badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _resultColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _bmiClassification.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: _resultColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                
                // Mascot speech-bubble advice
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/healthy_eating/images/titi patita.webp',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text('🐱', style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFEF3C7)),
                        ),
                        child: Text(
                          _titiAdvice,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF78350F),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Specialist Nutritionist referral block (if not normal)
          if (_needsNutritionist) ...[
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 450),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2), // Light pastel red/pink
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFCA5A5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.healing_rounded,
                      color: Color(0xFFEF4444),
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RECOMENDACIÓN VITAL',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF991B1B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Al no encontrarte en el rango Normal, te recomendamos consultar con un profesional de la salud o nutricionista para recibir una guía de alimentación personalizada y adecuada para vos.',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7F1D1D),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

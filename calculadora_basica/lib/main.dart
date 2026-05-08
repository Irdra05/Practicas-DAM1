import 'dart:io';

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MainApp());
}

/** Clase Main de la aplicación.
 * 
 */
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  State<MainApp> createState() => _mainApp();
}

class _mainApp extends State<MainApp> {
  String _resultado = '';
  String _ultimaPulsacion = '';
  bool _bloqueado = false;

  /** Este void se del refresco de pantalla de los botones al ser pulsados.
   * 
   */
  void _onPressed(String valor) {
    if (_bloqueado) return;
    setState(() {
      switch (valor.toUpperCase()) {
        case 'AC':
          _resultado = '';
          _ultimaPulsacion = 'AC';

        case 'DEL':
          if (_ultimaPulsacion != '=') {
            if (_resultado.isNotEmpty) _resultado = _resultado.substring(0, _resultado.length - 1);
            _ultimaPulsacion = 'DEL';
          }

        case '=':
          try {
            //Transformación del string
            _resultado = _resultado.replaceAll('x', '*').replaceAll(',', '.');
            ExpressionParser parser = GrammarParser();
            Expression expression = parser.parse(_resultado);

            num res = RealEvaluator(ContextModel()).evaluate(expression);

            _resultado = res.toString().replaceAll('.', ',');
            if (_resultado.endsWith(',0')) _resultado = _resultado.substring(0, _resultado.length - 2);
          } catch (e) {
            setState(() {
              _resultado = 'ERROR';
              _bloqueado = true;
            });
            Future.delayed(Duration(seconds: 3), () {
              setState(() {
                _resultado = '';       
                _bloqueado = false;
              });
            });
          } finally {
            _ultimaPulsacion = valor;
          }

        case '0':
          if (_ultimaPulsacion == '=') _resultado = '';
          if (_resultado.isNotEmpty) _resultado += valor;
          _ultimaPulsacion = valor;

        case ',':
          if (_ultimaPulsacion == '=') _resultado = '';
          if (_resultado.isEmpty) _resultado += '0' + valor;
          else _resultado += valor;
          _ultimaPulsacion = valor;

        case '+' || '-' || '/' || 'x':
          _resultado += valor;
          _ultimaPulsacion = valor;

        default:
          if (_ultimaPulsacion == '=') _resultado = '';
          _resultado += valor;
          _ultimaPulsacion = valor;
      }
    });
  }

  /**Este widget dibuja toda la estructura de la aplicación.
   * 
   */
  @override
  Widget build(BuildContext content) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            color: Colors.black87,
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _resultado.isEmpty ? '0' : _resultado,
                      style: TextStyle(fontSize: 65, color: Colors.white),
                    )
                  )
                ),
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Tile(contenido: 'DEL', color: Colors.blueGrey.shade700, funcion: () => _onPressed('DEL')), flex: 3),
                            Expanded(child: Tile(contenido: 'AC', color: Colors.blueGrey.shade700, funcion: () => _onPressed('AC')), flex: 3),
                            Expanded(child: Tile(contenido: '+', color: Colors.orangeAccent, funcion: () => _onPressed('+')), flex: 2),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Tile(contenido: '1', color: Colors.grey.shade700, funcion: () => _onPressed('1'))),
                            Expanded(child: Tile(contenido: '2', color: Colors.grey.shade700, funcion: () => _onPressed('2'))),
                            Expanded(child: Tile(contenido: '3', color: Colors.grey.shade700, funcion: () => _onPressed('3'))),
                            Expanded(child: Tile(contenido: '-', color: Colors.orangeAccent, funcion: () => _onPressed('-'))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Tile(contenido: '4', color: Colors.grey.shade700, funcion: () => _onPressed('4'))),
                            Expanded(child: Tile(contenido: '5', color: Colors.grey.shade700, funcion: () => _onPressed('5'))),
                            Expanded(child: Tile(contenido: '6', color: Colors.grey.shade700, funcion: () => _onPressed('6'))),
                            Expanded(child: Tile(contenido: 'x', color: Colors.orangeAccent, funcion: () => _onPressed('x'))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Tile(contenido: '7', color: Colors.grey.shade700, funcion: () => _onPressed('7'))),
                            Expanded(child: Tile(contenido: '8', color: Colors.grey.shade700, funcion: () => _onPressed('8'))),
                            Expanded(child: Tile(contenido: '9', color: Colors.grey.shade700, funcion: () => _onPressed('9'))),
                            Expanded(child: Tile(contenido: '/', color: Colors.orangeAccent, funcion: () => _onPressed('/'))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Tile(contenido: '0', color: Colors.grey.shade700, funcion: () => _onPressed('0')), flex: 2),
                            Expanded(child: Tile(contenido: ',', color: Colors.grey.shade700, funcion: () => _onPressed(',')), flex: 1),
                            Expanded(child: Tile(contenido: '=', color: Colors.orange, funcion: () => _onPressed('=')), flex: 1),
                          ],
                        ),
                      )
                    ],
                  )
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}

/** Esta clase dibuja los botones en pantalla.
 * 
 */
class Tile extends StatelessWidget {
  const Tile({super.key, required this.contenido, required this.color, required this.funcion});

  final String contenido;
  final Color color;
  final VoidCallback funcion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: RawMaterialButton(
        onPressed: funcion,
        fillColor: color,
        constraints: const BoxConstraints.expand(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Text(
          contenido,
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      )
    );
  }
}
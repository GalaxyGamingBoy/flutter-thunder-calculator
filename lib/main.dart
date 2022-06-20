import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thunder_calculator/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(MaterialApp(
    home: const ThunderCalculatorMain(),
    supportedLocales: L10n.all,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
  ));
}

class SettingsData {
  bool metricSystem;

  SettingsData(this.metricSystem);
}

class ThunderCalculatorMain extends StatefulWidget {
  const ThunderCalculatorMain({Key? key}) : super(key: key);

  @override
  State<ThunderCalculatorMain> createState() => _ThunderCalculatorMainState();
}

class _ThunderCalculatorMainState extends State<ThunderCalculatorMain> {
  // App Version
  String version = "1.3.0";

  // Other
  String timeType = "Sec";
  int timeMultiplier = 1;
  bool isInSeconds = true;

  final timeController = TextEditingController();
  final stopwatch = Stopwatch();
  Timer? refreshTimer;

  String kmAway = "";
  String distance = "";

  String stopwatchStr = "Start";
  String stopwatchTime = "0";

  // Settings Dara
  SettingsData settingsData = SettingsData(true);
  String distanceType = "km";

  void calculateDistance(String value)
  {
    int secondsBetween = int.parse(value) * timeMultiplier;
    int distanceInMeters = secondsBetween * 343;
    double distanceInKM = distanceInMeters / 1000;
    if (!settingsData.metricSystem)
      {
        distanceInKM /= 1.609;
      }
    kmAway = distanceInKM.toStringAsFixed(2);
  }

  @override
  void initState() {
    refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        stopwatchTime = stopwatch.elapsed.inSeconds.toString();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timeController.dispose();
    refreshTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    var appLoc = AppLocalizations.of(context);

    // Refresh Translations
    if (stopwatch.isRunning)
      {
        stopwatchStr = appLoc!.stopwatchEnd;
      }
    else
      {
        stopwatchStr = appLoc!.stopwatchStart;
      }

    if (settingsData.metricSystem)
    {
      distanceType = appLoc.distanceTypeKM;
    }
    else
    {
      distanceType = appLoc.distanceTypeMI;
    }

    return Scaffold(
      backgroundColor: Colors.black,

      // AppBar
      appBar: AppBar(
        title: Text(appLoc.title),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(5, 63, 94, 1),
        leading: GestureDetector(
          onTap: () async {
            settingsData = await Navigator.push(context, MaterialPageRoute(
                builder: (context) => const ThunderCalculatorSettings(),
                settings: RouteSettings(
                  arguments: settingsData
                )
            ));

            calculateDistance(timeController.text);
            distance = kmAway;
          },
          child: const Icon(Icons.settings),
        )
      ),

      // Main
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Image(
            image: AssetImage('assets/thunder.jpg'),
            height: 350.0,
            width: 750.0,
            fit: BoxFit.fitWidth,
          ),

          // SPACING
          const SizedBox(height: 50.0),

          // STOPWATCH
          Row(
            children: [
              const SizedBox(width: 25.0),
              Text(
                appLoc.stopwatchSegmentTitle,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 17.5
                ),
              )
            ],
          ),

          // STOPWATCH BUTTON
          Row(
            children: [
              const SizedBox(width: 25.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (stopwatch.isRunning)
                      {
                        // Stop time
                        stopwatch.stop();

                        // Change type to seconds
                        timeType = "Sec";
                        timeMultiplier = 1;
                        isInSeconds = true;

                        // Show time to user and pass it to field
                        timeController.text = stopwatch.elapsed.inSeconds.toString();
                        calculateDistance(timeController.text);

                        // Calculate distance
                        distance = kmAway;
                        stopwatch.reset();
                      }
                    else
                    {
                      stopwatch.start();
                    }
                  });
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(5, 63, 94, 1))
                ),
                child: Text(
                  stopwatchStr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                '$stopwatchTime sec',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0
                ),
              ),
            ],
          ),

          const SizedBox(height: 5.0),

          // TIME
          Row(
            children: [
              const SizedBox(width: 25.0),
              Text(
                appLoc.timeMeasuredSegmentTitle,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 17.5
                ),
              )
            ],
          ),

          // TIME INPUT
          Row(
            children: [
              const SizedBox(width: 20.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(const Size(210, 50)),
                  child: TextFormField(
                    controller: timeController,
                    cursorHeight: 27.5,
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)
                      )
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,

                    onChanged: (value) {
                      if (value != "")
                        {
                          // Calculate Distance
                          setState(() {
                            calculateDistance(value);
                            distance = kmAway;
                          });
                        }
                    },
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isInSeconds = !isInSeconds;
                    if (isInSeconds) {
                      timeType = "Sec";
                      timeMultiplier = 1;
                    } else {
                      timeType = "Min";
                      timeMultiplier = 60;
                    }
                    
                    calculateDistance(timeController.text);
                    distance = kmAway;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(5, 63, 94, 1))
                ),
                child: Text(
                  '$timeType | ${appLoc.change}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0
                  ),
                ),
              )
            ],
          ),

          // DISTANCE HINT
          Row(
            children: [
              const SizedBox(width: 25.0),
              Text(
                appLoc.distanceSegmentTitle,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 17.5
                ),
              )
            ],
          ),

          // DISTANCE
          Row(
            children: [
              const SizedBox(width: 25.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Text(
                  '$distance $distanceType',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0
                  ),
                ),
              )
            ],
          ),
        ],
      ),

      // Floating Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) => AlertDialog(
            title: Text(appLoc.helpSegmentTitle),
            content: Text(
                '''
                ${appLoc.helpParagraphA}
                                
                ${appLoc.helpParagraphB}    
                            
                ${appLoc.helpParagraphC}
                ''',
              textAlign: TextAlign.left,
            ),
            actions: [
              TextButton(onPressed: () => {
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: Text('${appLoc.helpSegmentTitle} - ${appLoc.more}'),
                  content: Text('''
                  ${appLoc.moreInfoParagraphA}  

                  ${appLoc.madeBy}
                  ${appLoc.translatedBy}
                  ${appLoc.version} $version'''
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(appLoc.back)),
                  ],
                ))
              }, child : Text(appLoc.more)),
              TextButton(onPressed: () => Navigator.pop(context), child: Text(appLoc.back))
            ],
          ));
        },
        child: const Icon(
          Icons.help_outline,
          size: 55.0,
        ),
      ),
    );
  }
}

class ThunderCalculatorSettings extends StatefulWidget {
  const ThunderCalculatorSettings({Key? key}) : super(key: key);

  @override
  State<ThunderCalculatorSettings> createState() => _ThunderCalculatorSettingsState();
}

class _ThunderCalculatorSettingsState extends State<ThunderCalculatorSettings> {
  String systemOfMeasurementStr = "Metric";

  SettingsData settingsData = SettingsData(true);

  @override
  Widget build(BuildContext context) {
    var appLoc = AppLocalizations.of(context);
    settingsData = ModalRoute.of(context)!.settings.arguments as SettingsData;

    setState(() {
      if (settingsData.metricSystem)
      {
        systemOfMeasurementStr = appLoc!.systemOfMeasurementMetric;
      }
      else
      {
        systemOfMeasurementStr = appLoc!.systemOfMeasurementImperial;
      }
    });

    return Scaffold(
      appBar: AppBar(
          title: Text('${appLoc!.title} - ${appLoc.settingsTitle}'),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(5, 63, 94, 1),
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50.0),
          Row(
            children: [

              // System Of Measurement
              const SizedBox(width: 25.0),
              Text(
                appLoc.systemOfMeasurementSegmentSettingsTitle,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 17.5
                ),
              )
            ],
          ),

          // CURRENT SOM
          Row(
            children: [
              const SizedBox(width: 25.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Text(
                  '${appLoc.current}: $systemOfMeasurementStr',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0
                  ),
                ),
              )
            ],
          ),

          // CHANGE SOM
          Row(
            children: [
              const SizedBox(width: 25.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    settingsData.metricSystem = !settingsData.metricSystem;
                  });
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(5, 63, 94, 1))
                ),
                child: Text(
                  appLoc.change,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0
                  ),
                ),
              ),
            ],
          ),

          // SAVE QUIT
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, settingsData);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(5, 63, 94, 1))
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Text(
                    appLoc.save,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 25.0),
            ],
          ),
        ],
      ),
    );
  }
}

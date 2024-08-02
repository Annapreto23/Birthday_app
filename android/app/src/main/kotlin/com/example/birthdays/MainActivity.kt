package com.example.birthdays

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.yourapp/birthday"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getNextBirthday") {
                val nextBirthday = getNextBirthdayFromFlutter()
                result.success(nextBirthday)
            }
        }
    }

    private fun getNextBirthdayFromFlutter(): String {
        // Ajoutez le code pour obtenir les informations du prochain anniversaire ici
        val nextBirthday = "Prochain anniversaire : Joshua le 12 janvier"
        return nextBirthday
    }
}


package com.jovelupe.wap

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Habilita edge-to-edge explícitamente para retrocompatibilidad pre-Android 15.
        // Flutter 3.22+ lo activa automáticamente en Android 15, pero esta llamada
        // asegura el mismo comportamiento en versiones anteriores (Android 10-14).
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }
}

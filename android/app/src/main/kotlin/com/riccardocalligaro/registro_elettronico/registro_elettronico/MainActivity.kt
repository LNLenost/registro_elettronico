package com.riccardocalligaro.registro_elettronico

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.riccardocalligaro.registro_elettronico/multi-account"
    private var widgetChannel: MethodChannel? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra("widget_route")?.let {
            widgetChannel?.invokeMethod("openWidgetRoute", it)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        widgetChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        widgetChannel!!.setMethodCallHandler { call, result ->
            if (call.method == "requestNotificationPermission") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    requestPermissions(
                        arrayOf("android.permission.POST_NOTIFICATIONS"),
                        1001
                    )
                }
                result.success(null)
            } else if (call.method == "updateWidgets") {
                val editor = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).edit()
                editor.putString("flutter.widget_agenda", call.argument<String>("agenda"))
                editor.putString("flutter.widget_grades", call.argument<String>("grades"))
                editor.putString("flutter.widget_timetable", call.argument<String>("timetable"))
                editor.putInt("flutter.themeColor", call.argument<Int>("color") ?: android.graphics.Color.RED)
                editor.apply()
                AgendaWidgetProvider().updateAll(this)
                GradesWidgetProvider().updateAll(this)
                TimetableWidgetProvider().updateAll(this)
                result.success(null)
            } else if (call.method == "updateWidgetTheme") {
                getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    .edit()
                    .putInt("flutter.themeColor", call.arguments as Int)
                    .apply()
                AgendaWidgetProvider().updateAll(this)
                GradesWidgetProvider().updateAll(this)
                TimetableWidgetProvider().updateAll(this)
                result.success(null)
            } else if (call.method == "getWidgetRoute") {
                result.success(intent.getStringExtra("widget_route"))
            } else if (call.method == "restartApp") {
                val packageManager: PackageManager = context.packageManager
                val intent: Intent? = packageManager.getLaunchIntentForPackage(context.packageName)
                val componentName: ComponentName? = intent?.component
                val mainIntent: Intent = Intent.makeRestartActivityTask(componentName)
                context.startActivity(mainIntent)
                Runtime.getRuntime().exit(0)
            }
        }
    }
}

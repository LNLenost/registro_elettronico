package com.lnlenost.registroelettronico

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.util.Log
import android.webkit.CookieManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val TAG = "DocenteLogin"
private const val CIEID_PACKAGE = "it.ipzs.cieid"
private const val CIEID_ACTIVITY = "it.ipzs.cieid.BaseActivity"
private const val CIEID_REQUEST = 0xC1E

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.lnlenost.registroelettronico/multi-account"
    private val COOKIE_CHANNEL = "com.lnlenost.registroelettronico/webview-cookies"
    private var widgetChannel: MethodChannel? = null
    private var pendingCieIdResult: MethodChannel.Result? = null

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != CIEID_REQUEST) return
        val url = data?.getStringExtra("URL")
        val error = data?.getIntExtra("ERROR", 0) ?: 0
        Log.i(TAG, "CieID result code=$resultCode hasUrl=${!url.isNullOrEmpty()} error=$error")
        pendingCieIdResult?.success(mapOf("resultCode" to resultCode, "url" to url, "error" to error))
        pendingCieIdResult = null
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra("widget_route")?.let {
            widgetChannel?.invokeMethod("openWidgetRoute", it)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // HttpOnly session cookies set during the SPID/CIE login are not visible to JavaScript.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COOKIE_CHANNEL)
            .setMethodCallHandler { call, result ->
                val cookieManager = CookieManager.getInstance()
                when (call.method) {
                    "getCookies" -> result.success(cookieManager.getCookie(call.arguments as String))
                    "clearCookies" -> cookieManager.removeAllCookies { result.success(it) }
                    // Debug builds: `am start --es docente_debug_web <path>` opens a teacher web
                    // page directly, so its requests can be mapped without touching the screen.
                    "getDebugWebPath" -> result.success(intent.getStringExtra("docente_debug_web"))
                    // Identity providers (e.g. CieID) hand off to their app through intent:// links.
                    "openIntentUri" -> {
                        try {
                            val target = Intent.parseUri(call.arguments as String, Intent.URI_INTENT_SCHEME)
                            target.addCategory(Intent.CATEGORY_BROWSABLE)
                            target.component = null
                            target.selector = null
                            startActivity(target)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    // Same as a browser following an App Link: open the URL only if a
                    // non-browser app (e.g. CieID) claims it, otherwise report false.
                    "openInNonBrowserApp" -> {
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                            result.success(false)
                        } else {
                            try {
                                val target = Intent(Intent.ACTION_VIEW, Uri.parse(call.arguments as String))
                                target.addCategory(Intent.CATEGORY_BROWSABLE)
                                target.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER)
                                startActivity(target)
                                result.success(true)
                            } catch (e: ActivityNotFoundException) {
                                result.success(false)
                            }
                        }
                    }
                    // CIE "redirection flow" from IPZS cieid-android-sdk: CieID authenticates
                    // and returns the URL the WebView must load to continue the login.
                    "launchCieId" -> {
                        pendingCieIdResult?.success(mapOf("error" to "superseded"))
                        try {
                            val target = Intent(Intent.ACTION_VIEW, Uri.parse(call.arguments as String))
                            target.setClassName(CIEID_PACKAGE, CIEID_ACTIVITY)
                            startActivityForResult(target, CIEID_REQUEST)
                            pendingCieIdResult = result
                            Log.i(TAG, "CieID launched")
                        } catch (e: Exception) {
                            Log.w(TAG, "CieID launch failed: ${e.javaClass.simpleName}")
                            result.success(mapOf("error" to "not_available"))
                        }
                    }
                    else -> result.notImplemented()
                }
            }

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
                val agenda = call.argument<String>("agenda")
                val grades = call.argument<String>("grades")
                val timetable = call.argument<String>("timetable")
                val color = call.argument<Number>("color")?.toInt() ?: android.graphics.Color.RED
                val editor = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).edit()
                editor.putString("flutter.widget_agenda", agenda)
                editor.putString("flutter.widget_grades", grades)
                editor.putString("flutter.widget_timetable", timetable)
                editor.putInt("flutter.themeColor", color)
                editor.apply()
                WearSync.publish(this, agenda, grades, timetable, color)
                AgendaWidgetProvider().updateAll(this)
                GradesWidgetProvider().updateAll(this)
                TimetableWidgetProvider().updateAll(this)
                result.success(null)
            } else if (call.method == "updateWidgetTheme") {
                getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    .edit()
                    .putInt("flutter.themeColor", (call.arguments as Number).toInt())
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

package com.riccardocalligaro.registro_elettronico

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews

abstract class BaseRegistroWidgetProvider : AppWidgetProvider() {
    abstract val layout: Int
    abstract val title: String
    abstract val contentId: Int
    abstract val route: String
    abstract val dataKey: String

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { update(context, manager, it) }
    }

    fun update(context: Context, manager: AppWidgetManager, id: Int) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val views = RemoteViews(context.packageName, layout)
        val color = prefs.getInt(COLOR_KEY, Color.WHITE)
        val textColor = if (isLight(color)) Color.BLACK else Color.WHITE
        views.setInt(R.id.widget_root, "setBackgroundColor", color)
        views.setTextColor(R.id.widget_title, textColor)
        views.setTextColor(contentId, textColor)
        views.setTextViewText(R.id.widget_title, title)
        views.setTextViewText(contentId, prefs.getString(dataKey, null) ?: "Apri l'app per sincronizzare")
        val intent = Intent(context, MainActivity::class.java).putExtra(ROUTE_KEY, route)
        val pendingIntent = PendingIntent.getActivity(
            context, route.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                (if (android.os.Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
        manager.updateAppWidget(id, views)
    }

    private fun isLight(color: Int): Boolean {
        val r = Color.red(color)
        val g = Color.green(color)
        val b = Color.blue(color)
        return (r * 299 + g * 587 + b * 114) >= 150000
    }

    fun updateAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val component = android.content.ComponentName(context, this::class.java)
        manager.getAppWidgetIds(component).forEach { update(context, manager, it) }
    }

    companion object {
        const val PREFS = "FlutterSharedPreferences"
        const val COLOR_KEY = "flutter.themeColor"
        const val AGENDA_KEY = "flutter.widget_agenda"
        const val GRADES_KEY = "flutter.widget_grades"
        const val TIMETABLE_KEY = "flutter.widget_timetable"
        const val ROUTE_KEY = "widget_route"
    }
}

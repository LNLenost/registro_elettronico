package com.riccardocalligaro.registro_elettronico

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class NextEventWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray
    ) {
        ids.forEach { update(context, manager, it) }
    }

    companion object {
        private const val PREFS = "FlutterSharedPreferences"
        private const val EVENT_KEY = "flutter.widget_next_event"

        fun update(context: Context, manager: AppWidgetManager, id: Int) {
            val views = RemoteViews(context.packageName, R.layout.widget_next_event)
            val event = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getString(EVENT_KEY, null)
            views.setTextViewText(
                R.id.widget_event,
                event ?: "Apri l'app per sincronizzare"
            )
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    (if (android.os.Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
            )
            views.setOnClickPendingIntent(R.id.widget_event, pendingIntent)
            manager.updateAppWidget(id, views)
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = android.content.ComponentName(
                context,
                NextEventWidgetProvider::class.java
            )
            manager.getAppWidgetIds(component).forEach { update(context, manager, it) }
        }
    }
}

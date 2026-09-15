package com.lnlenost.registroelettronico.wear

import android.content.Context
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.WearableListenerService

class WearSyncListenerService : WearableListenerService() {
    override fun onDataChanged(events: DataEventBuffer) {
        try {
            for (event in events) {
                if (event.type != com.google.android.gms.wearable.DataEvent.TYPE_CHANGED || event.dataItem.uri.path != "/registro/summary") continue
                val map = com.google.android.gms.wearable.DataMapItem.fromDataItem(event.dataItem).dataMap
                getSharedPreferences("registro", Context.MODE_PRIVATE).edit()
                    .putString("agenda", map.getString("agenda"))
                    .putString("grades", map.getString("grades"))
                    .putString("timetable", map.getString("timetable"))
                    .putInt("color", map.getInt("color"))
                    .putLong("updatedAt", map.getLong("updatedAt"))
                    .apply()
            }
        } finally {
            events.release()
        }
    }
}

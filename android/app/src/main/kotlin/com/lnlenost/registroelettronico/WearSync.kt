package com.lnlenost.registroelettronico

import android.content.Context
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable

object WearSync {
    fun publish(context: Context, agenda: String?, grades: String?, timetable: String?, color: Int) {
        val request = PutDataMapRequest.create("/registro/summary")
        request.dataMap.putString("agenda", agenda.orEmpty())
        request.dataMap.putString("grades", grades.orEmpty())
        request.dataMap.putString("timetable", timetable.orEmpty())
        request.dataMap.putInt("color", color)
        request.dataMap.putLong("updatedAt", System.currentTimeMillis())
        Wearable.getDataClient(context).putDataItem(request.asPutDataRequest().setUrgent())
    }
}

package com.lnlenost.registroelettronico.wear

import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.widget.LinearLayout
import android.widget.TextView

class MainActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val data = getSharedPreferences("registro", MODE_PRIVATE)
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(24, 24, 24, 24)
            setBackgroundColor(data.getInt("color", Color.RED))
        }
        fun item(title: String, value: String) = TextView(this).apply {
            text = "$title\n$value"
            setTextColor(Color.WHITE)
            textSize = 16f
            setPadding(0, 0, 0, 18)
        }
        layout.addView(item("Voti", data.getString("grades", "Apri l'app sul telefono per sincronizzare") ?: ""))
        layout.addView(item("Agenda", data.getString("agenda", "Nessun evento") ?: ""))
        layout.addView(item("Orario", data.getString("timetable", "Non disponibile") ?: ""))
        setContentView(layout)
    }
}

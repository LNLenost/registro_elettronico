package com.lnlenost.registroelettronico

class TimetableWidgetProvider : BaseRegistroWidgetProvider() {
    override val layout = R.layout.widget_timetable
    override val title = "Orario"
    override val contentId = R.id.widget_content
    override val route = "/timetable"
    override val dataKey = BaseRegistroWidgetProvider.TIMETABLE_KEY
}

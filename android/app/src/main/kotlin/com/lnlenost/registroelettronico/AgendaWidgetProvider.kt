package com.lnlenost.registroelettronico

class AgendaWidgetProvider : BaseRegistroWidgetProvider() {
    override val layout = R.layout.widget_agenda
    override val title = "Compiti in agenda"
    override val contentId = R.id.widget_content
    override val route = "/agenda"
    override val dataKey = BaseRegistroWidgetProvider.AGENDA_KEY
}

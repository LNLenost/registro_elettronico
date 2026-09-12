package com.riccardocalligaro.registro_elettronico

class GradesWidgetProvider : BaseRegistroWidgetProvider() {
    override val layout = R.layout.widget_grades
    override val title = "Ultimi voti"
    override val contentId = R.id.widget_content
    override val route = "/grades"
    override val dataKey = BaseRegistroWidgetProvider.GRADES_KEY
}

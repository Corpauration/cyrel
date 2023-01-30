package fr.corpauration.cyrel

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.text.format.DateFormat
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar
import java.util.Date
import java.util.Locale

class ScheduleWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val coursesSize = widgetData.getInt("size", -1)
            println("onUpdate courses size = $coursesSize")
            val courses: Bundle = Bundle()
            courses.putInt("size", coursesSize)
            if (coursesSize > 0) {
                val now = Date(System.currentTimeMillis())
                val nowCal = Calendar.getInstance()
                nowCal.time = now
                var j = 0
                var last = -1
                for (i in 0 until coursesSize) {
                    val d = Date(widgetData.getString("start_t_$i", "0").toString().toLong())
                    val dCal = Calendar.getInstance()
                    dCal.time = d
                    if (dCal.get(Calendar.YEAR) == nowCal.get(Calendar.YEAR) && dCal.get(Calendar.MONTH) == nowCal.get(
                            Calendar.MONTH
                        ) && dCal.get(Calendar.DAY_OF_WEEK) == nowCal.get(Calendar.DAY_OF_WEEK)
                    ) {
                        if (j > 0) {
                            courses.putBundle("$j", getSpace(widgetData, last, i))
                            j++
                        }
                        courses.putBundle("$j", getCourse(widgetData, i, j, last))
                        j++
                        last = i
                    }
                }
                courses.putInt("size", j)
            }
            val svcIntent: Intent = Intent(context, ScheduleWidgetService::class.java)
            svcIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            svcIntent.putExtra("courses", courses)
            svcIntent.data = Uri.parse(svcIntent.toUri(Intent.URI_INTENT_SCHEME))
            val views: RemoteViews = RemoteViews(context.packageName, R.layout.schedule)
            views.setRemoteAdapter(R.id.list, svcIntent)
            views.setTextViewText(R.id.day,
                DateFormat.format("EEEE", System.currentTimeMillis()).toString()
                    .replaceFirstChar { if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString() })
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun getCourse(widgetData: SharedPreferences, i: Int, j: Int, last: Int): Bundle {
        val course: Bundle = Bundle()
        course.putString("id", widgetData.getString("id_$i", "")!!)
        course.putString("start", widgetData.getString("start_$i", "")!!)
        course.putLong("start_t", widgetData.getString("start_t_$i", "0")!!.toLong())
        course.putString("end", widgetData.getString("end_$i", null))
        course.putLong("end_t", widgetData.getString("end_t_$i", "-1")!!.toLong())
        course.putInt("category", widgetData.getInt("category_$i", 0))
        course.putString("subject", widgetData.getString("subject_$i", null))
        course.putString("teachers", widgetData.getString("teachers_$i", "")!!)
        course.putString("rooms", widgetData.getString("rooms_$i", "")!!)
        if (j > 0) {
            val height = widgetData.getString("start_t_$i", "0")!!
                .toLong() - widgetData.getString("end_t_$last", "0")!!.toLong()
            course.putFloat("top", 72 * (height / 3600000.0 - 0.1).toFloat())
        }
        return course
    }

    private fun getSpace(widgetData: SharedPreferences, last: Int, i: Int): Bundle {
        val course: Bundle = Bundle()
        course.putBoolean("space", true)
        val height = widgetData.getString("start_t_$i", "0")!!.toLong() - widgetData.getString(
            "end_t_$last",
            "0"
        )!!.toLong()
        course.putFloat("size", 72 * (height / 3600000.0 - 0.1).toFloat())
        return course
    }


}
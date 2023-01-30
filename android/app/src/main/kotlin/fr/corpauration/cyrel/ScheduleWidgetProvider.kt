package fr.corpauration.cyrel

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class ScheduleWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val coursesSize = widgetData.getInt("size", -1)
            println("onUpdate courses size = $coursesSize")
            val courses: Bundle = Bundle()
            courses.putInt("size", coursesSize)
            if (coursesSize > 0) {
                for (i in 0 until coursesSize) {
                    courses.putBundle("$i", getCourse(widgetData, i))
                }
            }
            val svcIntent: Intent = Intent(context, ScheduleWidgetService::class.java)
            svcIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            svcIntent.putExtra("courses", courses)
            svcIntent.data = Uri.parse(svcIntent.toUri(Intent.URI_INTENT_SCHEME))
            val views: RemoteViews = RemoteViews(context.packageName, R.layout.schedule)
            views.setRemoteAdapter(R.id.list, svcIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun getCourse(widgetData: SharedPreferences, i: Int): Bundle {
        val course: Bundle = Bundle()
        course.putString("id", widgetData.getString("id_$i", "")!!)
        course.putString("start", widgetData.getString("start_$i", "")!!)
        course.putString("end", widgetData.getString("end_$i", null))
        course.putInt("category", widgetData.getInt("category_$i", 0))
        course.putString("subject", widgetData.getString("subject_$i", null))
        course.putString("teachers", widgetData.getString("teachers_$i", "")!!)
        course.putString("rooms", widgetData.getString("rooms_$i", "")!!)
        return course
    }


}
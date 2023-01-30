package fr.corpauration.cyrel

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.res.ColorStateList
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.widget.LinearLayout
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class ScheduleViewsService(context: Context?, intent: Intent?) : RemoteViewsService.RemoteViewsFactory {
    private val context: Context
    private val intent: Intent
    private val appWidgetId: Int
    private val courses: Bundle
    private val size: Int

    init {
        this.context = context!!
        this.intent = intent!!
        appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        courses = intent.getBundleExtra("courses")!!
        size = courses.getInt("size")
    }

    override fun onCreate() {
        println("CREATED VIEW SERVICE")
    }

    override fun onDataSetChanged() {

    }

    override fun onDestroy() {

    }

    override fun getCount(): Int {
        println("courses.size = $size")
        return size
    }

    override fun getViewAt(pos: Int): RemoteViews {
        val course: RemoteViews = RemoteViews(context.packageName, R.layout.course)
        val start: String = courses.getBundle("$pos")!!.getString("start", "").split(" ")[1].substring(0, 5)
        val end: String = if (courses.getBundle("$pos")!!.getString("end", "") == "") "Fin non indiqué"
        else courses.getBundle("$pos")!!.getString("end", "").split(" ")[1].substring(0, 5)

        course.setTextViewText(R.id.course_start, start)
        course.setTextViewText(R.id.course_end, end)
        course.setTextViewText(R.id.course_subject, courses.getBundle("$pos")!!.getString("subject", ""))
        course.setTextViewText(R.id.course_teachers, courses.getBundle("$pos")!!.getString("teachers", "Pas de professeurs indiqué").replace(",", ", ", false))
        course.setTextViewText(R.id.course_rooms, courses.getBundle("$pos")!!.getString("rooms", "Pas de salle indiqué").split(",").map { if (it.startsWith("PAU ")) it.split(" ")[1] else it }.joinToString(", "))
        val color: Int = when (courses.getBundle("$pos")!!.getInt("category", 0)) {
            1 -> Color.argb(255, 196, 38, 38)
            2 -> Color.argb(255, 38, 38, 196)
            3 -> Color.argb(255, 38, 196, 38)
            4 -> Color.argb(255, 38, 196, 196)
            5 -> Color.argb(255, 56, 56, 56)
            6 -> Color.argb(255, 100, 56, 196)
            7 -> Color.argb(255, 196, 100, 56)
            8 -> Color.argb(255, 196, 56, 196)
            else -> Color.parseColor("#2196f3")
        }
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//            course.setColorStateList(R.id.course, "setColorFilter", ColorStateList.valueOf(color))
//        } else {
            course.setInt(R.id.course, "setBackgroundColor", color)
//        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            course.setViewOutlinePreferredRadius(R.id.course, 5F, android.util.TypedValue.COMPLEX_UNIT_DIP)
            course.setViewLayoutHeight(R.id.course, 72F + 72 * 0.4F, android.util.TypedValue.COMPLEX_UNIT_DIP)
        }

        return course
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(pos: Int): Long {
        return pos.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}

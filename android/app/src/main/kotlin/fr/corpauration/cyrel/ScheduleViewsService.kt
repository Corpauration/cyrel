package fr.corpauration.cyrel

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews
import android.widget.RemoteViewsService

class ScheduleViewsService(context: Context?, intent: Intent?) :
    RemoteViewsService.RemoteViewsFactory {
    private val context: Context
    private val intent: Intent
    private val appWidgetId: Int
    private lateinit var courses: Bundle
    private var size: Int = 0

    init {
        this.context = context!!
        this.intent = intent!!
        appWidgetId = intent.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID
        )
        setCourses()
    }

    private fun setCourses() {
        courses = intent.getBundleExtra("courses")!!
        size = courses.getInt("size")
    }

    override fun onCreate() {
    }

    override fun onDataSetChanged() {
        intent.putExtra(
            "courses", ScheduleWidgetProvider.jsonToBundle(
                ScheduleWidgetProvider.restoreFromPreferences(context)
            )
        )
        setCourses()
    }

    override fun onDestroy() {

    }

    override fun getCount(): Int {
        return size
    }

    override fun getViewAt(pos: Int): RemoteViews {
        if (courses.getBundle("$pos")!!.getBoolean("space")) {
            val space = RemoteViews(context.packageName, R.layout.course)
            space.setInt(R.id.course, "setBackgroundResource", Color.argb(0, 0, 0, 0))
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                space.setViewLayoutHeight(
                    R.id.course,
                    courses.getBundle("$pos")!!.getFloat("size", 1F),
                    android.util.TypedValue.COMPLEX_UNIT_DIP
                )
            }
            space.setTextViewText(R.id.course_start, "")
            space.setTextViewText(R.id.course_end, "")
            space.setTextViewText(
                R.id.course_subject, ""
            )
            return space
        }
        val course = RemoteViews(context.packageName, R.layout.course)
        val start: String =
            courses.getBundle("$pos")!!.getString("start", "").split(" ")[1].substring(0, 5)
        val end: String =
            if (courses.getBundle("$pos")!!.getString("end", "") == "") "Fin non indiqué"
            else courses.getBundle("$pos")!!.getString("end", "").split(" ")[1].substring(0, 5)

        course.setTextViewText(R.id.course_start, start)
        course.setTextViewText(R.id.course_end, end)
        course.setTextViewText(
            R.id.course_subject,
            courses.getBundle("$pos")!!
                .getString("subject", "") + "\n" + courses.getBundle("$pos")!!.getString(
                "teachers",
                "Pas de professeurs indiqué"
            ) + "\n" + courses.getBundle("$pos")!!.getString("rooms", "Pas de salle indiqué")
                .split(",")
                .joinToString(", ") { if (it.startsWith("PAU ")) it.split(" ")[1] else it }
                .replace(",", ", ", false)
        )
        val color: Int = when (courses.getBundle("$pos")!!.getInt("category", 0)) {
            1 -> R.drawable.r1
            2 -> R.drawable.r2
            3 -> R.drawable.r3
            4 -> R.drawable.r4
            5 -> R.drawable.r5
            6 -> R.drawable.r6
            7 -> R.drawable.r7
            8 -> R.drawable.r8
            else -> R.drawable.rd
        }
        course.setInt(R.id.course, "setBackgroundResource", color)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val height = courses.getBundle("$pos")!!.getLong("end_t") - courses.getBundle("$pos")!!
                .getLong("start_t")
            course.setViewLayoutHeight(
                R.id.course,
                72 * (height / 3600000.0 - 0.1).toFloat(),
                android.util.TypedValue.COMPLEX_UNIT_DIP
            )
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

package fr.corpauration.cyrel

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.text.format.DateFormat
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import java.util.Calendar
import java.util.Date
import java.util.Locale


class ScheduleWidgetProvider : HomeWidgetProvider(), MethodChannel.MethodCallHandler {
    private var number = 0
    private val flutterLoader: FlutterLoader = FlutterInjector.instance().flutterLoader()
    private lateinit var backgroundEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel
    private lateinit var dartEntrypoint: DartEntrypoint
    private lateinit var mCtx: Context
    private lateinit var appWidgetManager: AppWidgetManager
    private lateinit var appWidgetIds: IntArray

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        mCtx = context
        this.appWidgetManager = appWidgetManager
        this.appWidgetIds = appWidgetIds

        if (!flutterLoader.initialized()) {
            flutterLoader.startInitialization(context)
        }
        flutterLoader.ensureInitializationComplete(context, null)
        if (this::backgroundEngine.isInitialized) {
            backgroundEngine.destroy()
        }
        backgroundEngine = FlutterEngine(context)
        methodChannel = MethodChannel(
            backgroundEngine.dartExecutor.binaryMessenger,
            "id.flutter/cyrel_widgets",
            JSONMethodCodec.INSTANCE
        )
        methodChannel.setMethodCallHandler(this)
        dartEntrypoint = DartEntrypoint(
            flutterLoader.findAppBundlePath(),
            "package:cyrel/utils/android_widgets.dart",
            "widgetEntrypoint"
        )
        backgroundEngine.dartExecutor.executeDartEntrypoint(dartEntrypoint, listOf())
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        when (intent?.action) {
            "android.intent.action.TIME_SET", "android.intent.action.TIMEZONE_CHANGED", "android.appwidget.action.APPWIDGET_UPDATE" -> {
                if (this::mCtx.isInitialized && this::appWidgetManager.isInitialized && this::appWidgetIds.isInitialized) {
                    onUpdate(mCtx, appWidgetManager, appWidgetIds)
                } else {
                    appWidgetManager = AppWidgetManager.getInstance(context)
                    appWidgetIds =
                        appWidgetManager.getAppWidgetIds(ComponentName(context!!, javaClass))
                    mCtx = context
                    onUpdate(mCtx, appWidgetManager, appWidgetIds)
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "offline" -> println("Update the widget with offline state")
            "notConnected" -> println("Show the text 'not connected'")
            "setCourses" -> {
                println(call.arguments::class)
                println((call.arguments as JSONArray))
                val json = call.arguments as JSONArray
                val courses = jsonToBundle(json)
                saveCoursesToPreferences(mCtx, json)

                for (appWidgetId in appWidgetIds) {
                    val svcIntent = Intent(mCtx, ScheduleWidgetService::class.java)
                    svcIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                    svcIntent.putExtra("courses", courses)
                    svcIntent.putExtra("fixAndroidBug", number++)
                    svcIntent.data = Uri.parse(svcIntent.toUri(Intent.URI_INTENT_SCHEME))
                    val views = RemoteViews(mCtx.packageName, R.layout.schedule)
                    views.setRemoteAdapter(R.id.list, svcIntent)
                    views.setTextViewText(R.id.day,
                        DateFormat.format("EEEE", System.currentTimeMillis()).toString()
                            .replaceFirstChar { if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString() })
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.list)
                }
            }
        }
        result.success(true)

        backgroundEngine.destroy()
    }

    companion object {
        private fun getCourse(list: List<CourseEntity>, i: Int, j: Int, last: Int): Bundle {
            val courseEntity = list[i]
            val course = Bundle()
            course.putString("id", courseEntity.id)
            course.putString("start", courseEntity.start)
            course.putLong("start_t", courseEntity.startT)
            course.putString("end", courseEntity.end)
            course.putLong("end_t", courseEntity.endT ?: -1)
            course.putInt("category", courseEntity.category)
            course.putString("subject", courseEntity.subject)
            course.putString("teachers", courseEntity.teachers)
            course.putString("rooms", courseEntity.rooms)
            if (j > 0) {
                val height = courseEntity.startT - (list[last].endT ?: 0)
                course.putFloat("top", 72 * (height / 3600000.0 - 0.1).toFloat())
            }
            return course
        }

        private fun getSpace(list: List<CourseEntity>, last: Int, i: Int): Bundle {
            val courseEntity = list[i]
            val course = Bundle()
            course.putBoolean("space", true)
            val height = courseEntity.startT - (list[last].endT ?: 0)
            course.putFloat("size", 72 * (height / 3600000.0 - 0.1).toFloat())
            return course
        }

        fun jsonToBundle(json: JSONArray): Bundle {
            val list = mutableListOf<CourseEntity>()
            for (i in 0 until json.length()) {
                val obj = json.getJSONObject(i)
                list.add(
                    CourseEntity(
                        obj.getString("id"),
                        obj.getString("start"),
                        obj.getLong("start_t"),
                        obj.getString("end"),
                        obj.getLong("end_t"),
                        obj.getInt("category"),
                        obj.getString("subject"),
                        obj.getString("teachers"),
                        obj.getString("rooms")
                    )
                )
            }

            val courses = Bundle()
            courses.putInt("size", list.size)
            if (list.size > 0) {
                val now = Date(System.currentTimeMillis())
                val nowCal = Calendar.getInstance()
                nowCal.time = now
                var j = 0
                var last = -1
                for (i in 0 until list.size) {
                    if (j > 0) {
                        courses.putBundle("$j", getSpace(list, last, i))
                        j++
                    }
                    courses.putBundle("$j", getCourse(list, i, j, last))
                    j++
                    last = i
                }
                courses.putInt("size", j)
            }

            return courses
        }

        fun saveCoursesToPreferences(context: Context, json: JSONArray) {
            val settings: SharedPreferences = context.getSharedPreferences("courses_widget", 0)
            val editor = settings.edit()
            editor.putString("json", json.toString())
            editor.apply()
        }

        fun restoreFromPreferences(context: Context): JSONArray {
            val settings: SharedPreferences = context.getSharedPreferences("courses_widget", 0)
            return JSONArray(settings.getString("json", "[]"))
        }
    }
}
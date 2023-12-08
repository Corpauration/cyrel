package fr.corpauration.cyrel

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(flutterEngine!!)

        MethodChannel(
            this.flutterEngine!!.dartExecutor.binaryMessenger,
            "fr.corpauration.cyrel/main_activity"
        ).apply {
            setMethodCallHandler { method, result ->
                when (method.method) {
                    "disableBatteryOptimizations" -> {
                        // FIXME Will be banned on Play Store
                        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP_MR1) {
                            val pkg = packageName
                            val pm = getSystemService(PowerManager::class.java)
                            if (!pm.isIgnoringBatteryOptimizations(pkg)) {
                                val i: Intent =
                                    Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                                        .setData(Uri.parse("package:$pkg"))
                                startActivity(i)
                            }
                        }
                    }
                }
                result.success(true)
            }
        }
    }
}

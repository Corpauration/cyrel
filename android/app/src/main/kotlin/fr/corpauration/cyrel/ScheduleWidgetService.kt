package fr.corpauration.cyrel

import android.content.Intent
import android.widget.RemoteViewsService

class ScheduleWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent?): RemoteViewsFactory {
        return ScheduleViewsService(applicationContext, intent)
    }
}

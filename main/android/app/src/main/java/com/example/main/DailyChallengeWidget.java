
package com.example.main;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;

public class DailyChallengeWidget extends AppWidgetProvider {

    static String challengeText = "Niciun challenge";
    static boolean completed = false;

    public static void updateWidget(Context context) {
        AppWidgetManager manager = AppWidgetManager.getInstance(context);
        ComponentName widget = new ComponentName(context, DailyChallengeWidget.class);
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.daily_challenge_widget);

        views.setTextViewText(R.id.challenge_text, challengeText);
        views.setTextViewText(R.id.challenge_status, completed ? "✅ Completat" : "❌ Necompletat");

        manager.updateAppWidget(widget, views);
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        updateWidget(context);
    }
}

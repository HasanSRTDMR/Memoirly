package com.memoirly.memoirly

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class DailyQuoteWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: android.content.SharedPreferences,
  ) {
    val rawQuote =
        widgetData.getString("daily_quote_text", null)
            ?: context.getString(R.string.widget_quote_placeholder)
    // Match in-app _DailyQuoteCard: '"' + body + '"'
    val quote = "\"$rawQuote\""
    val author = widgetData.getString("daily_quote_author", null)?.trim().orEmpty()

    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.widget_daily_quote).apply {
            setTextViewText(R.id.widget_quote_text, quote)
            if (author.isNotEmpty()) {
              setTextViewText(R.id.widget_quote_author, "\u2014 $author")
              setViewVisibility(R.id.widget_quote_author, android.view.View.VISIBLE)
            } else {
              setViewVisibility(R.id.widget_quote_author, android.view.View.GONE)
            }

            val intent =
                Intent(context, MainActivity::class.java).apply {
                  flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
            val pi =
                PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
            setOnClickPendingIntent(R.id.widget_root, pi)
          }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}

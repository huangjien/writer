package com.huangjien.novel

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.media.app.NotificationCompat.MediaStyle
import androidx.media.session.MediaButtonReceiver
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private lateinit var mediaSession: MediaSessionCompat
  private lateinit var channel: MethodChannel

  private val notificationId = 1001
  private val channelId = "novel_reader_playback"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    channel = MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      "com.huangjien.novel/media_control",
    )

    createNotificationChannel()

    mediaSession = MediaSessionCompat(this, "NovelReader")
    val stateBuilder = PlaybackStateCompat.Builder()
      .setActions(
        PlaybackStateCompat.ACTION_PLAY or
          PlaybackStateCompat.ACTION_PAUSE or
          PlaybackStateCompat.ACTION_PLAY_PAUSE or
          PlaybackStateCompat.ACTION_SKIP_TO_NEXT or
          PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS or
          PlaybackStateCompat.ACTION_STOP
      )
    mediaSession.setPlaybackState(
      stateBuilder.setState(PlaybackStateCompat.STATE_PAUSED, 0, 1f).build()
    )
    mediaSession.setCallback(object : MediaSessionCompat.Callback() {
      override fun onPlay() {
        channel.invokeMethod("play", null)
        mediaSession.isActive = true
        mediaSession.setPlaybackState(
          stateBuilder.setState(PlaybackStateCompat.STATE_PLAYING, 0, 1f).build()
        )
        updateNotification(isPlaying = true)
      }
      override fun onPause() {
        channel.invokeMethod("pause", null)
        mediaSession.setPlaybackState(
          stateBuilder.setState(PlaybackStateCompat.STATE_PAUSED, 0, 1f).build()
        )
        updateNotification(isPlaying = false)
      }
      override fun onStop() {
        channel.invokeMethod("stop", null)
        mediaSession.setPlaybackState(
          stateBuilder.setState(PlaybackStateCompat.STATE_STOPPED, 0, 1f).build()
        )
        mediaSession.isActive = false
        cancelNotification()
      }
      override fun onSkipToNext() {
        channel.invokeMethod("next", null)
      }
      override fun onSkipToPrevious() {
        channel.invokeMethod("prev", null)
      }
    })
    mediaSession.isActive = true
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val nm = getSystemService(NotificationManager::class.java)
      val channel = NotificationChannel(
        channelId,
        "Playback Controls",
        NotificationManager.IMPORTANCE_LOW,
      )
      nm.createNotificationChannel(channel)
    }
  }

  private fun updateNotification(isPlaying: Boolean) {
    val playIntent = MediaButtonReceiver.buildMediaButtonPendingIntent(
      this,
      PlaybackStateCompat.ACTION_PLAY,
    )
    val pauseIntent = MediaButtonReceiver.buildMediaButtonPendingIntent(
      this,
      PlaybackStateCompat.ACTION_PAUSE,
    )
    val nextIntent = MediaButtonReceiver.buildMediaButtonPendingIntent(
      this,
      PlaybackStateCompat.ACTION_SKIP_TO_NEXT,
    )
    val prevIntent = MediaButtonReceiver.buildMediaButtonPendingIntent(
      this,
      PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS,
    )
    val stopIntent = MediaButtonReceiver.buildMediaButtonPendingIntent(
      this,
      PlaybackStateCompat.ACTION_STOP,
    )

    val builder = NotificationCompat.Builder(this, channelId)
      .setSmallIcon(android.R.drawable.ic_media_play)
      .setContentTitle("Novel Reader")
      .setContentText("Text-to-speech playback")
      .setOngoing(isPlaying)
      .setShowWhen(false)
      .addAction(
        android.R.drawable.ic_media_previous,
        "Prev",
        prevIntent,
      )
      .addAction(
        if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play,
        if (isPlaying) "Pause" else "Play",
        if (isPlaying) pauseIntent else playIntent,
      )
      .addAction(
        android.R.drawable.ic_media_next,
        "Next",
        nextIntent,
      )
      .addAction(
        android.R.drawable.ic_delete,
        "Stop",
        stopIntent,
      )
      .setStyle(
        MediaStyle()
          .setMediaSession(mediaSession.sessionToken)
          .setShowActionsInCompactView(0, 1, 2)
      )

    NotificationManagerCompat.from(this).notify(notificationId, builder.build())
  }

  private fun cancelNotification() {
    NotificationManagerCompat.from(this).cancel(notificationId)
  }

  override fun onDestroy() {
    if (::mediaSession.isInitialized) mediaSession.release()
    cancelNotification()
    super.onDestroy()
  }
}

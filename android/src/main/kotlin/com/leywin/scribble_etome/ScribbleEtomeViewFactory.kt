package com.leywin.scribble_etome
import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ScribbleEtomeViewFactory(private val channel: MethodChannel) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // You may need to pass initialization parameters from Flutter to your HandwrittenView
        val creationParams = args as Map<String?, Any?>?
        return HandwrittenView(context, creationParams, channel)
    }
}
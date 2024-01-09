package com.leywin.scribble_etome

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import android.view.HandwrittenView2
import android.view.View
import android.widget.Space
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.system.exitProcess


class HandwrittenView(
    context: Context, creationParams: Map<String?, Any?>?, channel: MethodChannel
) : PlatformView {
    private var buttonLock = false
    private var initFlag = false
    var mHandwrittenView: HandwrittenView2? = null
    private val mHandler = InitHandler(creationParams)
    private var layout: View = View.inflate(context, R.layout.activity_main, null)

    override fun getView(): View {
        return layout
    }

    override fun dispose() {
        mHandwrittenView?.destoryView()
    }

    init {
        mHandwrittenView = layout.findViewById(R.id.handwrittenView)
        val topPaddingHeight = creationParams!!["topPaddingHeight"] as Int
        setPadToppingHeight(topPaddingHeight)
        context.resources.displayMetrics.also {
            mScreenW = it.widthPixels
            mScreenH = it.heightPixels
        }

        channel.setMethodCallHandler { call, result ->
            onMethodCall(call, result)
        }

        mHandler.sendEmptyMessageDelayed(DELAY_REFRESH, DELAY_TIME.toLong())
    }

    private fun setPadToppingHeight(padToppingHeight: Int) {
        val spaceView = layout.findViewById<Space>(R.id.padTopping)
        val layoutParams = spaceView.layoutParams
        layoutParams.height = padToppingHeight
        spaceView.layoutParams = layoutParams
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "undo" -> undo()
            "redo" -> redo()
            "clear" -> clear()
            "setPenStroke" -> {
                val strokeType = call.argument<Int>("strokeType")
                setPenStroke(strokeType ?: 0)
            }

            "save" -> {
                val imageName = call.argument<String>("imageName")

                save(result, imageName!!)
            }

            "destroy" -> onDestroy()
//            "load" -> {
//                val bitArr = call.argument<ByteArray>("bitMap")
//                load(bitArr!!,context,result)
//            }

        }
    }


    private fun undo() {
        if (!buttonLock && initFlag) {
            buttonLock = true
            mHandwrittenView?.undo()
            buttonLock = false
        }
    }

    private fun redo() {
        if (!buttonLock && initFlag) {
            buttonLock = true
            mHandwrittenView?.redo()
            buttonLock = false
        }
    }

    private fun clear() {
        if (!buttonLock && initFlag) {
            buttonLock = true
            mHandwrittenView?.clear()
            buttonLock = false
        }
    }

    private fun setPenStroke(strokeType: Int) {
        if (initFlag) {
            mHandwrittenView?.setPenStroke(strokeType)
        }
    }

    private fun save(result: MethodChannel.Result, imageName: String) {
        if (!buttonLock) {
            buttonLock = true
            val bitmap: Bitmap = mHandwrittenView!!.bitmap
            val byteArrayOutputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, byteArrayOutputStream)
            val byteArray = byteArrayOutputStream.toByteArray()
            val (isSaved, errorMessage) = saveBitmap(bitmap, imageName)
            if (isSaved) {
                result.success(byteArray)
            } else {
                result.error("SAVE_ERROR", errorMessage, null)
            }
            buttonLock = false
        }
    }


    private val isSpecialPanel: Boolean
        get() = false

    @SuppressLint("HandlerLeak")
    internal inner class InitHandler(private val creationParams: Map<String?, Any?>?) :
        Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)
            when (msg.what) {
                DELAY_REFRESH -> object : Thread() {
                    override fun run() {
                        var count = 0
                        while (mHandwrittenView!!.height <= 0) {
                            try {
                                sleep(50)
                            } catch (e: InterruptedException) {
                                // TODO Auto-generated catch block
                                e.printStackTrace()
                            }
                            if (count++ > 40) {
                                Log.d(TAG, "Flash test : ++++++++ removeCallbacks")
                                exitProcess(0)
                            }
                            Log.d(
                                TAG,
                                "Flash test : ++++++++ mView.getHeight() = " + mHandwrittenView!!.height + ", count = " + count
                            )
                        }
                        // Upper-left coordinates
                        mLeft = 0
                        mTop = mScreenH - mHandwrittenView!!.height
                        // Lower-right coordinates
                        mRight = mScreenW
                        mBottom = mScreenH
                        if (isSpecialPanel) {
                            mHandwrittenView!!.initNative(
                                Rect(
                                    mScreenW - mRight,
                                    mScreenH - mBottom,
                                    mScreenW - mLeft,
                                    mScreenH - mTop
                                ), false, Rect(
                                    mScreenW - mFilterRight,
                                    mScreenH - mFilterBottom,
                                    mScreenW - mFilterLeft,
                                    mScreenH - mFilterTop
                                )
                            )
                        } else {
                            mHandwrittenView!!.initNative(
                                Rect(mLeft, mTop, mRight, mBottom),
                                false,
                                Rect(mFilterLeft, mFilterTop, mFilterRight, mFilterBottom)
                            )
                        }
                        initFlag = true
                        val imageName = creationParams!!["imageName"] as String
                        val bitmap = loadBitmap(imageName)
                        if (bitmap != null) {
                            mHandwrittenView!!.bitmap = bitmap
                            mHandwrittenView!!.refreshBitmap()
                        }
                    }
                }.start()
            }
        }
    }


    private fun onDestroy() {
        if (initFlag) {
            mHandwrittenView!!.clear()
            mHandwrittenView!!.exit()
        }
        mHandwrittenView!!.destoryView()
    }

    companion object {

        private var mScreenH = 0
        private var mScreenW = 0
        private var mLeft = 0
        private var mTop = 0
        private var mRight = 0
        private var mBottom = 0
        private const val mFilterLeft = 0
        private const val mFilterTop = 0
        private const val mFilterRight = 0
        private const val mFilterBottom = 0
        const val DELAY_REFRESH = 0
        const val DELAY_TIME = 100
        private const val HANDWRITE_SAVE_PATH = "/storage/emulated/0/Etome/"
        private val TAG = HandwrittenView::class.java.simpleName

        fun saveBitmap(bitmap: Bitmap, imageName: String?): Pair<Boolean, String?> {
            val directory = File(HANDWRITE_SAVE_PATH)
            if (!directory.exists() && !directory.mkdirs()) {
                val errMsg = "Failed to create directory: $HANDWRITE_SAVE_PATH"
                Log.e("HandwrittenView", errMsg)
                return Pair(false, errMsg)
            }

            val fileName =
                imageName ?: SimpleDateFormat("yyyyMMdd-HHmmss", Locale.getDefault()).format(Date())
            val filePath = "$HANDWRITE_SAVE_PATH${fileName}.png"
            val file = File(filePath)

            if (file.exists()) {
                val deleted = file.delete()
                if (!deleted) {
                    val errMsg = "Failed to delete existing file: $filePath"
                    Log.e("HandwrittenView", errMsg)
                    return Pair(false, errMsg)
                }
            }

            return try {
                FileOutputStream(filePath).use { fos ->
                    bitmap.compress(Bitmap.CompressFormat.PNG, 90, fos)
                }
                Pair(true, null) // Success, no error message
            } catch (e: IOException) {
                val errMsg = "Error saving bitmap: ${e.localizedMessage}"
                Log.e("HandwrittenView", errMsg, e)
                Pair(false, errMsg) // Failure, with error message
            }
        }


        fun loadBitmap(imageName: String): Bitmap? {
            val filePath = "$HANDWRITE_SAVE_PATH${imageName}.png"
            val file = File(filePath)

            if (!file.exists()) {
                Log.e("HandwrittenView", "File not found: $filePath")
                return null
            }

            val options = BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888
                inScaled = false
                inMutable = true
            }

            return try {
                BitmapFactory.decodeFile(filePath, options)
            } catch (e: Exception) {
                Log.e("HandwrittenView", "Error loading bitmap: ${e.localizedMessage}", e)
                null
            }
        }
    }
}
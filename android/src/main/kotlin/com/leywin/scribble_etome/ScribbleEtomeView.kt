package com.leywin.scribble_etome
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
import android.widget.TextView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import io.flutter.plugin.platform.PlatformView
import java.io.ByteArrayOutputStream
import java.io.IOException
import kotlin.system.exitProcess


class HandwrittenView(context: Context, creationParams: Map<String?, Any?>?, channel: MethodChannel) : PlatformView  {
    private var buttonLock = false
    private var initFlag = false
    var mHandwrittenView: HandwrittenView2? = null
    private var strokeTv: TextView? = null
    private val mHandler = InitHandler(creationParams)
    private var strokeType = 0
    private var layout: View = View.inflate(context, R.layout.activity_main, null)

    override fun getView(): View {
        return layout
    }

    override fun dispose() {
        mHandwrittenView?.destoryView()
    }
    init {
        mHandwrittenView = layout.findViewById(R.id.handwrittenView)
//        layout.findViewById<View>(R.id.undo).setOnClickListener { onClick(it) }
//        layout.findViewById<View>(R.id.redo).setOnClickListener { onClick(it) }
//        layout.findViewById<View>(R.id.clear).setOnClickListener { onClick(it) }
//        layout.findViewById<View>(R.id.stroke).setOnClickListener { onClick(it) }
//        layout.findViewById<View>(R.id.save).setOnClickListener { onClick(it) }
//        strokeTv = layout.findViewById(R.id.stroke)
        context.resources.displayMetrics.also {
            mScreenW = it.widthPixels
            mScreenH = it.heightPixels
        }

        channel.setMethodCallHandler { call, result ->
            onMethodCall(call, result)
        }

        mHandler.sendEmptyMessageDelayed(DELAY_REFRESH, DELAY_TIME.toLong())
    }

    private fun onMethodCall(call: MethodCall, result:  MethodChannel.Result) {
        when (call.method) {
            "undo" -> undo()
            "redo" -> redo()
            "clear" -> clear()
            "setPenStroke" -> {
                val strokeType = call.argument<Int>("strokeType")
                setPenStroke(strokeType ?: 0)
            }
            "save" -> {
                val fileName = call.argument<String>("imageName")
                save(result, fileName!!)
            }
            "destroy" -> onDestroy()
            "load" -> {
                val bitArr = call.argument<ByteArray>("bitArray")
                load(bitArr!!)
            }

        }
    }

    private fun load(byteArr: ByteArray){
        val bitmap = BitmapFactory.decodeByteArray(byteArr, 0, byteArr.size)
        mHandwrittenView!!.bitmap = bitmap
        mHandwrittenView!!.refreshBitmap()
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

    private fun save(result: MethodChannel.Result,fileName: String) {
        if (!buttonLock) {
            buttonLock = true
            val bitmap: Bitmap = mHandwrittenView!!.bitmap
            buttonLock = false
            val byteArrayOutputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, byteArrayOutputStream)
            val byteArray = byteArrayOutputStream.toByteArray()
            saveBitmap(mHandwrittenView!!.bitmap, fileName)
            result.success(byteArray)
        }
    }




    private val isSpecialPanel: Boolean

        get() = false

    internal inner class InitHandler(private val creationParams: Map<String?, Any?>?) : Handler(Looper.getMainLooper()) {
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
                                ), false,
                                Rect(
                                    mScreenW - mFilterRight,
                                    mScreenH - mFilterBottom,
                                    mScreenW - mFilterLeft,
                                    mScreenH - mFilterTop
                                )
                            )
                        } else {
                            mHandwrittenView!!.initNative(
                                Rect(mLeft, mTop, mRight, mBottom), false,
                                Rect(mFilterLeft, mFilterTop, mFilterRight, mFilterBottom)
                            )
                        }
                        initFlag = true
                        /**
                         * After initialization is complete, load and refresh the previously saved handwriting image,
                         * and perform writing and drawing operations on the original handwriting.
                         */
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

//    fun onResume() {
//        super.onResume()
//        Log.e("TAG", "onResume")
//    }
//
//     fun onPause() {
//        super.onPause()
//        Log.e("TAG", "onPause")
//    }

    private fun onDestroy() {
        if (initFlag) {
            mHandwrittenView!!.clear()
            mHandwrittenView!!.exit()
        }
        mHandwrittenView!!.destoryView()
//        super.onDestroy()
    }

    companion object {
        /**
         * 1. Put the system-compiled classes.jar in ROOT_DIR/app/libs
         * 2. Code addition search: Make classes.jar compile before android.jar (the jar package name is subject to the actual name,
         *    note the RK path: out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/classes-header.jar)
         * 3. Rebuild Project
         */
        /** English description, the same as above
         * 1. Put the compiled classes. jar in ROOT_ DIR/app/libs
         * 2. Code addition search: 使classes.jar包编译先于android.jar (The jar package name shall be subject to the actual name.
         *    Note the RK path: out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/classes header. jar)
         * 3.Rebuild Project
         */
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

        fun saveBitmap(bitmap: Bitmap, imageName: String?) {
            val directory = File(HANDWRITE_SAVE_PATH)
            if (!directory.exists() && !directory.mkdirs()) {
                Log.e("HandwrittenView", "Failed to create directory: $HANDWRITE_SAVE_PATH")
                return
            }

            val fileName = imageName ?: SimpleDateFormat("yyyyMMdd-HHmmss", Locale.getDefault()).format(Date())
            val filePath = "$HANDWRITE_SAVE_PATH${fileName}.png"

            try {
                FileOutputStream(filePath).use { fos ->
                    bitmap.compress(Bitmap.CompressFormat.PNG, 90, fos)
                }
            } catch (e: IOException) {
                Log.e("HandwrittenView", "Error saving bitmap: ${e.localizedMessage}", e)
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
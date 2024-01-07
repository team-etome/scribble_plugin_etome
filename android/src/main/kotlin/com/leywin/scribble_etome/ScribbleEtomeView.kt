package com.leywin.scribble_etome
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.os.Handler
import android.os.Message
import android.util.DisplayMetrics
import android.util.Log
import android.view.HandwrittenView2
import android.view.LayoutInflater
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


class HandwrittenView(context: Context, creationParams: Map<String?, Any?>?, channel: MethodChannel) : PlatformView  {
    private var buttonLock = false
    private var initFlag = false
    public var mHandwrittenView: HandwrittenView2? = null
    private var strokeTv: TextView? = null
    private val mHandler = InitHandler()
    private var strokeType = 0
    private var layout: View = LayoutInflater.from(context).inflate(R.layout.activity_main, null, false)

    override fun getView(): View {
        return layout
    }

    override fun dispose() {
        mHandwrittenView?.destoryView()
    }
    init {
        mHandwrittenView = layout.findViewById(R.id.handwrittenView)
        layout.findViewById<View>(R.id.undo).setOnClickListener { onClick(it) }
        layout.findViewById<View>(R.id.redo).setOnClickListener { onClick(it) }
        layout.findViewById<View>(R.id.clear).setOnClickListener { onClick(it) }
        layout.findViewById<View>(R.id.stroke).setOnClickListener { onClick(it) }
        layout.findViewById<View>(R.id.save).setOnClickListener { onClick(it) }
        strokeTv = layout.findViewById(R.id.stroke)

        val metrics = DisplayMetrics()
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
            "save" -> save(result)
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

    private fun save(result: MethodChannel.Result) {
        if (!buttonLock) {
            buttonLock = true
            val bitmap: Bitmap = mHandwrittenView!!.bitmap
            buttonLock = false
            val byteArrayOutputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, byteArrayOutputStream)
            val byteArray = byteArrayOutputStream.toByteArray()
            result.success(byteArray)
        }
    }


    fun onClick(v: View) {
        when (v.id) {
            R.id.undo -> object : Thread() {
                override fun run() {
                    if (!buttonLock) {
                        buttonLock = true
                        if (initFlag) {
                            mHandwrittenView!!.undo()
                        }
                        buttonLock = false
                    }
                }
            }.start()

            R.id.redo -> object : Thread() {
                override fun run() {
                    if (!buttonLock) {
                        buttonLock = true
                        if (initFlag) {
                            mHandwrittenView!!.redo()
                        }
                        buttonLock = false
                    }
                }
            }.start()

            R.id.clear -> object : Thread() {
                override fun run() {
                    if (!buttonLock) {
                        buttonLock = true
                        if (initFlag) {
                            mHandwrittenView!!.clear()
                        }
                        buttonLock = false
                    }
                }
            }.start()

            R.id.stroke -> {
                strokeType++
                if (strokeType >= 5) {
                    strokeType = 0
                }
                Log.e(TAG, "Current strokeType:$strokeType")
                var stroke = "Ballpoint Pen"
                when (strokeType) {
                    0 -> {
                        stroke = "Ballpoint Pen"
                    }
                    1 -> {
                        stroke = "Fountain Pen"
                    }
                    2 -> {
                        stroke = "Pencil"
                    }
                    3 -> {
                        stroke = "Linear Eraser"
                    }
                    4 -> {
                        stroke = "Area Eraser"
                    }
                }
                strokeTv!!.text = stroke
                mHandwrittenView!!.setPenStroke(strokeType)
            }

            R.id.save -> if (!buttonLock) {
                buttonLock = true
                val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
                val fileName = "testSave"

                saveBitmap(mHandwrittenView!!.bitmap, fileName)
//                onBackPressed()
                buttonLock = false
            }
        }
    }

    private val isSpecialPanel: Boolean

        private get() = false

    internal inner class InitHandler : Handler() {
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
                                System.exit(0)
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
                        val bitmap = loadBitmap("testSave")
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

    fun onDestroy() {
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
        const val HANDWRITER_SAVE_PATH = "/storage/emulated/0/HandWriter/"
        private val TAG = HandwrittenView::class.java.simpleName
        fun saveBitmap(bitmap: Bitmap, imagename: String?) {
            var imagename = imagename
            val file = File(HANDWRITER_SAVE_PATH)
            if (!file.exists()) {
                val flag = file.mkdirs()
            }
            if (imagename == null) {
                val df = SimpleDateFormat("yyyyMMdd-HHmmss")
                imagename = df.format(Date())
            }
            val path = HANDWRITER_SAVE_PATH + imagename + ".png"
            var fos: FileOutputStream? = null
            try {
                fos = FileOutputStream(path)
                if (fos != null) {
                    bitmap.compress(Bitmap.CompressFormat.PNG, 90, fos)
                    fos.close()
                }
                return
            } catch (e: Exception) {
                Log.v("xml_log_err", "" + e.toString())
                e.printStackTrace()
            }
        }

        fun loadBitmap(imagename: String): Bitmap? {
            val opts =
                BitmapFactory.Options()
            opts.inPreferredConfig = Bitmap.Config.ARGB_8888
            opts.inScaled = false
            opts.inMutable = true
            val path =
                HANDWRITER_SAVE_PATH + imagename + ".png"
            val file = File(path)
            return if (!file.exists()) {
                null
            } else BitmapFactory.decodeFile(path, opts)
        }
    }
}
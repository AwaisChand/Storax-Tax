package com.storatax.app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterFragmentActivity() {
    private val pdfPickerChannel = "storatax/pdf_picker"
    private val pdfPickRequest = 7191
    private var pdfPickResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            pdfPickerChannel,
        ).setMethodCallHandler { call, result ->
            if (call.method == "pickPdf") {
                if (pdfPickResult != null) {
                    result.error("already_active", "PDF picker is already open", null)
                    return@setMethodCallHandler
                }
                pdfPickResult = result
                val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                    type = "application/pdf"
                    addCategory(Intent.CATEGORY_OPENABLE)
                    putExtra(
                        Intent.EXTRA_MIME_TYPES,
                        arrayOf("application/pdf", "application/octet-stream"),
                    )
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                startActivityForResult(
                    Intent.createChooser(intent, "Select PDF"),
                    pdfPickRequest,
                )
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == pdfPickRequest) {
            val pending = pdfPickResult
            pdfPickResult = null
            if (resultCode == Activity.RESULT_OK) {
                val uri = data?.data
                pending?.success(uri?.let { copyUriToCache(it) })
            } else {
                pending?.success(null)
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun copyUriToCache(uri: Uri): String? {
        var name = "receipt.pdf"
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (index >= 0 && cursor.moveToFirst()) {
                val displayName = cursor.getString(index)
                if (!displayName.isNullOrBlank()) {
                    name = displayName
                }
            }
        }
        if (!name.lowercase().endsWith(".pdf")) {
            name = "$name.pdf"
        }
        val dir = File(cacheDir, "picked_pdfs").apply { mkdirs() }
        val outFile = File(dir, "${System.currentTimeMillis()}_$name")
        val input = contentResolver.openInputStream(uri) ?: return null
        input.use { stream ->
            FileOutputStream(outFile).use { output ->
                stream.copyTo(output)
            }
        }
        return if (outFile.exists() && outFile.length() > 0) outFile.absolutePath else null
    }
}

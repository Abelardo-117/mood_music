package com.moodmusic.local_media;

import android.content.Context;
import android.media.MediaCodec;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.media.MediaMuxer;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicBoolean;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public final class MoodMusicLocalMediaPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private MethodChannel channel;
    private File cache;
    private ExecutorService worker;
    private final AtomicBoolean busy = new AtomicBoolean(false);
    private volatile boolean attached;
    private final Handler main = new Handler(Looper.getMainLooper());
    @Override public void onAttachedToEngine(FlutterPluginBinding binding) {
        cache = binding.getApplicationContext().getCacheDir();
        worker = Executors.newSingleThreadExecutor();
        attached = true;
        channel = new MethodChannel(binding.getBinaryMessenger(), "moodmusic/local_media");
        channel.setMethodCallHandler(this);
    }
    @Override public void onDetachedFromEngine(FlutterPluginBinding binding) {
        attached = false;
        channel.setMethodCallHandler(null);
        worker.shutdownNow();
    }
    @Override public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (!call.method.equals("extractAudio")) { result.notImplemented(); return; }
        String path = call.argument("path");
        if (path == null) { result.error("input", "Selecciona un video.", null); return; }
        if (!busy.compareAndSet(false, true)) { result.error("busy", "Ya se está procesando un video.", null); return; }
        worker.execute(() -> {
            try {
                File output = extract(path);
                main.post(() -> {
                    if (attached) result.success(output.getAbsolutePath());
                    else { output.delete(); output.getParentFile().delete(); }
                });
            } catch (Exception error) {
                final String message = error instanceof IOException ? error.getMessage() : "No se pudo procesar este video. Prueba un MP4 con sonido AAC.";
                main.post(() -> { if (attached) result.error("extract", message, null); });
            } finally { busy.set(false); }
        });
    }
    private File extract(String path) throws Exception {
        File input = new File(path).getCanonicalFile();
        String root = cache.getCanonicalPath() + File.separator;
        if (!input.getPath().startsWith(root) || !input.isFile()) throw new IOException("No se pudo acceder al video seleccionado.");
        if (input.length() == 0 || input.length() > 300L * 1024 * 1024) throw new IOException("El video debe pesar entre 1 byte y 300 MB.");
        File directory = new File(cache, "mood_import_" + UUID.randomUUID());
        if (!directory.mkdir()) throw new IOException("No hay espacio para preparar el audio.");
        File output = new File(directory, "extracted.m4a");
        MediaExtractor extractor = new MediaExtractor();
        MediaMuxer muxer = null;
        boolean started = false, success = false;
        try {
            extractor.setDataSource(input.getAbsolutePath());
            int selected = -1;
            boolean hasAudio = false;
            MediaFormat format = null;
            for (int i = 0; i < extractor.getTrackCount(); i++) {
                MediaFormat candidate = extractor.getTrackFormat(i);
                String mime = candidate.getString(MediaFormat.KEY_MIME);
                if (mime != null && mime.startsWith("audio/")) hasAudio = true;
                if ("audio/mp4a-latm".equals(mime)) { selected = i; format = candidate; break; }
            }
            if (!hasAudio) throw new IOException("Este video no contiene una pista de sonido.");
            if (selected < 0) throw new IOException("El sonido de este video no es AAC. Prueba un MP4 con audio AAC o importa un archivo de audio.");
            extractor.selectTrack(selected);
            muxer = new MediaMuxer(output.getAbsolutePath(), MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
            int track = muxer.addTrack(format);
            muxer.start(); started = true;
            ByteBuffer buffer = ByteBuffer.allocateDirect(2 * 1024 * 1024);
            MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();
            long first = -1, previous = -1, bytes = 0;
            int samples = 0;
            while (extractor.getSampleTrackIndex() >= 0) {
                if (Thread.currentThread().isInterrupted()) throw new IOException("Extracción cancelada.");
                int flags = extractor.getSampleFlags();
                if ((flags & MediaExtractor.SAMPLE_FLAG_ENCRYPTED) != 0) throw new IOException("No se pueden importar videos protegidos.");
                if (Build.VERSION.SDK_INT >= 28) {
                    long needed = extractor.getSampleSize();
                    if (needed > 8 * 1024 * 1024) throw new IOException("La pista de audio no es compatible.");
                    if (needed > buffer.capacity()) buffer = ByteBuffer.allocateDirect((int) needed);
                }
                buffer.clear();
                int size = extractor.readSampleData(buffer, 0);
                if (size < 0) break;
                long time = extractor.getSampleTime();
                if (first < 0) first = time;
                long timestamp = Math.max(0, time - first);
                if (timestamp < previous) throw new IOException("El video contiene tiempos de audio inválidos.");
                previous = timestamp;
                bytes += size;
                if (bytes > 99L * 1024 * 1024) throw new IOException("El audio extraído supera el límite de 100 MB.");
                info.set(0, size, timestamp, (flags & MediaExtractor.SAMPLE_FLAG_SYNC) != 0 ? MediaCodec.BUFFER_FLAG_KEY_FRAME : 0);
                muxer.writeSampleData(track, buffer, info);
                samples++;
                if (!extractor.advance()) break;
            }
            if (samples == 0) throw new IOException("La pista de sonido está vacía.");
            muxer.stop(); started = false;
            if (output.length() > 100L * 1024 * 1024) throw new IOException("El audio extraído supera 100 MB.");
            success = true;
            return output;
        } finally {
            extractor.release();
            if (muxer != null) {
                if (started) { try { muxer.stop(); } catch (RuntimeException ignored) {} }
                try { muxer.release(); } catch (RuntimeException ignored) {}
            }
            if (!success) { output.delete(); directory.delete(); }
        }
    }
}

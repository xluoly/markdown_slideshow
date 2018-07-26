# Architecture

## Architecture of Camera1

android.hardware.Camera

三个工作模式：

1. Preview
2. Capture
3. Video recording

![](camera1_block.png)

## Limitations of Camera1

* 难以增加新的功能，如：快速拍照、零延迟拍照等
* 无法实现针对每帧的控制
* 无法实现RAW格式拍照

## Architecture of Camera2

android.hardware.camera2

![](camera2_simple_model.png)

## Features of Camera2

* 允许用户更好的控制聚焦、曝光等
* 可以对每个视频帧进行独立控制
* 可以保存Sensor RAW data
* 更灵活的图像后期处理

## Camera1 vs Camera2

![](camera1_vs_camera2.png)

## Camera2主要的几个类

* CameraManager：最顶层的管理类，提供检测系统摄像头、打开摄像头等操作
* CameraCharacteristics：用于描述特定摄像头所支持的各种特性，通过CameraManager来获取
* CameraDevice：代表系统摄像头设备
* CameraCaptureSession：摄像头建立会话的类，预览、拍照和录影都要先通过它建立Session来实现，数据通过内部类StateCallback和CaptureCallback返回
* CameraRequest和CameraRequest.Builder：对摄像头的设定和控制，以及拍照、预览和录像等都是通过发送请求实现

## Camera2主要的几个类

![](camera2_classes.png)

# Camera2 应用 -- 拍照

## 框图

![](base_block.png)

## 拍照的流程

![](take_picture.png)

## 获取CameraManager

```
mCameraManager = (CameraManager) 
                 activity.getSystemService(Context.CAMERA_SERVICE);
```

## 查询摄像头

```
private String getCameraId(CAMERA camera) {
    int lensFacing = (camera == CAMERA.EXT) ?
            CameraCharacteristics.LENS_FACING_FRONT :
            CameraCharacteristics.LENS_FACING_BACK;
    try {
        for (String cameraId : mCameraManager.getCameraIdList()) {
            CameraCharacteristics characteristics
                    = mCameraManager.getCameraCharacteristics(cameraId);

            if (characteristics.get(CameraCharacteristics.LENS_FACING) == lensFacing) {
                return cameraId;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return "";
}
```

## 打开摄像头设备

```
String cameraId = getCameraId(camera);
mCameraManager.openCamera(cameraId, mDeviceStateCallback, mBackgroundHandler);
```

## 建立Session

```
SurfaceTexture texture = mTextureView.getSurfaceTexture();
texture.setDefaultBufferSize(mPreviewSize.getWidth(), mPreviewSize.getHeight());
Surface surface = new Surface(texture);
mPreviewRequestBuilder = mCameraDevice.createCaptureRequest(
                             CameraDevice.TEMPLATE_PREVIEW);
mPreviewRequestBuilder.addTarget(surface);
mCameraDevice.createCaptureSession(Arrays.asList(surface, mImageReader.getSurface()),
        new CameraCaptureSession.StateCallback() {
            @Override
            public void onConfigured(@NonNull CameraCaptureSession session) {
                mPreviewSession = session;
                updatePreview();
            }
            @Override
            public void onConfigureFailed(@NonNull CameraCaptureSession session) {
            }
        }, mBackgroundHandler);
```

## 请求预览

```
private void updatePreview() {
    ...
    mPreviewRequestBuilder.set(CaptureRequest.CONTROL_AF_MODE,
            CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
    setAutoFlash(mPreviewRequestBuilder);
    mPreviewRequest = mPreviewRequestBuilder.build();
    mCaptureSession.setRepeatingRequest(mPreviewRequest,
            mCaptureCallback, mBackgroundHandler);
    ...
}
```

## Take Picture

```
final CaptureRequest.Builder captureBuilder =
        mCameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
captureBuilder.addTarget(mImageReader.getSurface());

captureBuilder.set(CaptureRequest.CONTROL_AF_MODE,
        CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
setAutoFlash(captureBuilder);

int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
captureBuilder.set(CaptureRequest.JPEG_ORIENTATION, getOrientation(rotation));

CameraCaptureSession.CaptureCallback CaptureCallback
        = new CameraCaptureSession.CaptureCallback() {

    @Override
    public void onCaptureCompleted(@NonNull CameraCaptureSession session,
                                   @NonNull CaptureRequest request,
                                   @NonNull TotalCaptureResult result) {
    }
};

mCaptureSession.stopRepeating();
mCaptureSession.abortCaptures();
mCaptureSession.capture(captureBuilder.build(), CaptureCallback, null);
```

## 保存Image

```
private final ImageReader.OnImageAvailableListener mOnImageAvailableListener
        = new ImageReader.OnImageAvailableListener() {

    @Override
    public void onImageAvailable(ImageReader reader) {
        mBackgroundHandler.post(new ImageSaver(reader.acquireNextImage(), mFile));
    }

};
```

# Camera2 应用 -- 录像

## 流程
* 打开Camera设备，与拍照的过程一样
* 设置参数，建立MediaRecorder
* 从获取MediaRecorder的input surface，建立Capture Session
* Session发送repeating request获取视频
* start MediaRecorder

## 系统框图

![](continuous_capture.png)

## 设置MediaRecorder

```
mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
mMediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
mMediaRecorder.setOutputFile(mNextVideoAbsolutePath);
mMediaRecorder.setVideoEncodingBitRate(10000000);
mMediaRecorder.setVideoFrameRate(30);
mMediaRecorder.setVideoSize(mVideoSize.getWidth(), mVideoSize.getHeight());
mMediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
switch (mSensorOrientation) {
    case SENSOR_ORIENTATION_DEFAULT_DEGREES:
        mMediaRecorder.setOrientationHint(DEFAULT_ORIENTATIONS.get(rotation));
        break;
    case SENSOR_ORIENTATION_INVERSE_DEGREES:
        mMediaRecorder.setOrientationHint(INVERSE_ORIENTATIONS.get(rotation));
        break;
}
mMediaRecorder.prepare();
```

## 建立Session

```
SurfaceTexture texture = mTextureView.getSurfaceTexture();
texture.setDefaultBufferSize(mPreviewSize.getWidth(), mPreviewSize.getHeight());
mPreviewBuilder = mCameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
List<Surface> surfaces = new ArrayList<>();
Surface previewSurface = new Surface(texture);
surfaces.add(previewSurface);
mPreviewBuilder.addTarget(previewSurface);
Surface recorderSurface = mMediaRecorder.getSurface();
surfaces.add(recorderSurface);
mPreviewBuilder.addTarget(recorderSurface);
mCameraDevice.createCaptureSession(surfaces, new CameraCaptureSession.StateCallback() {
    @Override
    public void onConfigured(@NonNull CameraCaptureSession cameraCaptureSession) {
        mPreviewSession = cameraCaptureSession;
        updatePreview();
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mMediaRecorder.start();
            }
        });
    }, mBackgroundHandler);
}
```

# CDR7010项目的录影

## 流程

* 实例化MediaCodec作为H.264 encoder，获取input surface
* 通过OpenGL创建一个surface用于接收camera的图像输出
* 创建capture session，传入OpenGL surface
* 发送repeating request获取连续的视频流
* OpenGL将camera输出的图像texture渲染到MediaCodec input surface
* MediaCodec对input surface进行编码，输出H.264数据流

## 系统框图

![](dashcam_architecture.png)

## 创建OpenGL surface

```
int texture = GLDrawer2D.initTex();
mInputSurface = new SurfaceTexture(texture);
mInputSurface.setDefaultBufferSize(1920, 1080);
mInputSurface.setOnFrameAvailableListener(EGLRenderer.this);
```

## 建立Capture Session

```
Surface surface = new Surface(surfaceTexture);
mCaptureBuilder = mCameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
mCaptureBuilder.addTarget(surface);
mCameraDevice.createCaptureSession(Collections.singletonList(surface),
        new CameraCaptureSession.StateCallback() {
    @Override
    public void onConfigured(@NonNull CameraCaptureSession cameraCaptureSession) {
        mCaptureSession = cameraCaptureSession;
        updatePreview();
    }
    @Override
    public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
    }
}, mBackgroundHandler);
```

## 渲染图像

```
@Override //OnFrameAvailableListener
public void onFrameAvailable(SurfaceTexture surfaceTexture) {
    mRenderHandler.sendEmptyMessage(MSG_UPDATE_FRAME);
}

private void drawFrame() {
    mInputSurface.updateTexImage();
    mInputSurface.getTransformMatrix(mTmpMatrix);
    mTextureController.setMatrix(mTmpMatrix);
    mEncoderSurface.makeCurrent();
    GLES20.glViewport(0, 0, 1920, 1080);
    mTextureController.draw();
    mEncoderSurface.setPresentationTime(mInputSurface.getTimestamp());
    if (mGroupOsd != null) {
        mGroupOsd.draw();
    }
    if (mFrameListener != null) {
        mFrameListener.frameAvailableSoon();
    }
    mEncoderSurface.swapBuffers();
}

```

## 与MediaRecorder录影的差异

* MediaRecorder：将MediaRecorder input surface传给Camera，图像数据直接输出到MediaRecorder surface
* MediaCodec：需要借助OpenGL渲染，必须将camera图像数据输出到OpenGL创建的一个中间SurfaceTexture，再用OpenGL将Texture渲染到MediaCodec input surface

## Camera2与Camera1的使用差异

![](diff_table.png)

## 参考资料

* [googlesamples/android-Camera2Basic](https://github.com/googlesamples/android-Camera2Basic)

* [googlesamples/android-Camera2Video](https://github.com/googlesamples/android-Camera2Video)

## The End

![](Thank-you.jpg)


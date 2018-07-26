# 问题现象
## 问题现象
* MP4 录影文件在 Windows Media Player 中播放出现马赛克或者绿屏

![](windows_media_player.png)

## 问题现象
* MP4 录影文件使用 VLC 和 ffplay 等播放器进行播放，画面显示正常

![](VLC_player.png)

## 重现方法
1. 持续录影 20 小时以上
2. 将最近录影 MP4 文件在Windows Media Player中播放

# 问题分析
## 确定是 Muxer 还是 Codec 的问题

* 如果是 Muxer 的问题，相关代码文件是 MPEG4Writer.cpp
* 如果是 Codec 的问题，相关代码可能需要联系高通处理

## 保持 Codec 不变，转换 Container
* 转换封装格式，保持 Codec 数据不变，将 MP4 转为 mpeg-ts 文件，去除 Audio track，只保留 Video track，依旧存在同样问题
* 初步排除Container的问题，怀疑是Codec的问题

```
$ ffmpeg -i 2017-12-28-06-29-43.mp4 -vcodec copy -an 2017-12-28-06-29-43.ts
```

## 保持 Codec 不变，重新封装相同 Container
* 使用 ffmpeg 从原 MP4 文件提取 Video track，再封装成新的 MP4，保持 Codec 数据不变，依旧存在同样问题 
* 进一步锁定Codec的问题

```
$ ffmpeg -i 2017-12-28-06-29-43.mp4 -vcodec copy -an -bsf:v h264_mp4toannexb \
 2017-12-28-06-29-43.h264
$ ffmpeg -i 2017-12-28-06-29-43.h264 -vcodec copy 2017-12-28-06-29-43-ffmpeg.mp4
```

## 重新 Encode，重新封装相同 Container
* 使用 ffmpeg 从原 MP4 文件提取 Video track，再封装成新的 MP4，使用 ffmpeg 重新 Encode，原来的问题没有了
* 基本可以确定是 Codec 的问题了

```
$ ffmpeg -i 2017-12-28-06-29-43.mp4 -vcodec copy -an -bsf:v h264_mp4toannexb \
 2017-12-28-06-29-43.h264
$ ffmpeg -i 2017-12-28-06-29-43.h264 2017-12-28-06-29-43-ffmpeg-transcode.mp4
```

## 联系高通技术支持协助分析 Codec
1. 详细描述问题现象并上传问题 MP4 文件
2. 高通技术支持工程师一开始想推卸，VLC能够播放，这不是高通Codec的问题，然后我将自己
用ffmpeg分析的过程和结果跟他详细说明，说出我的判断依据，请他帮忙分析是否为Codec存在
兼容性问题，他才同意接下该问题，帮忙进一步分析

## 初次判断可能是multi-slice的原因
1. 高通技术支持工程师依据经验判断可能是**我们自己**打开了 H.264 multi-slice 的原因，
Windows Media Player 可能不支持 multi-slice，高通 base code 默认关闭 multi-slice
2. 打开 Video Codec 相关的 log，重新启动 Encoder

```
  $ adb root
  $ adb shell "setprop vidc.debug.level 7"
  $ adb shell "echo 0x101f > /sys/kernel/debug/msm_vidc/debug_level"
  $ adb shell "echo 0x1f > /sys/kernel/debug/msm_vidc/fw_level"
  $ adb logcat -b all -c
  $ adb logcat -b all -v threadtime > all.log
```

3. 查看 log 确实有打开 multi-slice

```
01-06 08:51:45.654 569 569 D OMX-VENC: bool venc_dev::venc_enable_low_latency(): 
enable multislice mode with slice_size = 4096
```

## multi-slice 的修改记录

* 查看前面这段 log 对应的代码的提交记录，显示为 2015 年的提交，提交者也不是 Askey 的工程师，
这显然不是我们**自己修改出来的问题**，可以确定是高通 base code 就已经存在的问题，所以跟高通
技术支持工程师咨询修改办法，是否需要 revert 这个 commit

```
  commit f2fa16bbf572b1c1190655d8f6877fdd409dde67
  Author: Maheshwar Ajja <majja@codeaurora.org>
  Date: Mon Aug 17 17:54:47 2015 +0530

  mm-video-v4l2: vidc: venc: enable low latency mode

  By default 2D-2S mode will be enabled in video hardware and
  it has few hardware limitations in below usecases so enable
  1D-1S mode to video hardware using low latency mode to avoid
  hardware limitations
  ...
  Change-Id: I1201dc8f49cc1c77c9d8ee821ccba42668146db7

  mm-video-v4l2/vidc/venc/inc/video_encoder_device_v4l2.h | 6 ++++
  mm-video-v4l2/vidc/venc/src/video_encoder_device_v4l2.cpp | 128 +++++----
  2 files changed, 114 insertions(+), 20 deletions(-)
```

## 问题另有原因

* 高通再次分析发现问题不是这个原因，可能是 H264 slice header idr\_pic\_id 超过 
65535 造成，因为之前有客户遇到类似问题。借助媒体分析工具 Elecard StreamEye 分析，
问题 MP4 的 idr\_pic\_id 确实都超过了 65535，没有问题的 MP4 的 idr\_pic\_id 都没有超过 65535

![](idr_pic_id_overflow.png)

## 核对 Spec
* 查阅 H.264 Sepc，确实有规定 idr_pic_id 的范围在 0 ~ 65535 之间

```
dr_pic_id identifies an IDR picture. The values of idr_pic_id in all the slices 
of an IDR picture shall remain unchanged. When two consecutive access units in 
decoding order are both IDR access units, the value of idr_pic_id in the slices 
of the first such IDR access unit shall differ from the idr_pic_id in the second
such IDR access unit. The value of idr_pic_id shall be in the range of 0 to 
65535, inclusive.
```

# 问题确定
## 加速问题重现
* 重现该问题，得到 idr_pic_id 值在 65535 前后的两个 MP4 文件进行比较
* idr\_pic\_id 的值是根据 I-Frame 依次递增，代码中设置 I-Frame 的间隔为 1s. 达到 65535 需要的时间为：

```
  65535 / (60 * 60) = 18.2(hours)
```

* 为了缩短验证所需要的时间，可以修改设置，使得每个 Frame 都是 I-Frame，以帧率为 25fps
计算的话，达到 65535 需要的时间缩短为原来的 1/25，大约 45 分钟

## 加速问题重现

```
  android/frameworks/av/media/libstagefright$ git diff
  diff --git a/media/libstagefright/ACodec.cpp b/media/libstagefright/ACodec.cpp
  index 80ea25d..ff4e8ca 100644
  --- a/media/libstagefright/ACodec.cpp
  +++ b/media/libstagefright/ACodec.cpp
  @@ -3551,7 +3551,8 @@ status_t ACodec::setupAVCEncoderParameters(const sp<AMessage> &msg) {
           h264type.bUseHadamard = OMX_TRUE;
           h264type.nRefFrames = 1;
           h264type.nBFrames = 0;
  -        h264type.nPFrames = setPFramesSpacing(iFrameInterval, frameRate);
  +        h264type.nPFrames = 0;
  +        //h264type.nPFrames = setPFramesSpacing(iFrameInterval, frameRate);
           if (h264type.nPFrames == 0) {
               h264type.nAllowedPictureTypes = OMX_VIDEO_PictureTypeI;
           }
  @@ -3566,6 +3567,8 @@ status_t ACodec::setupAVCEncoderParameters(const sp<AMessage> &msg) {
       }

       setBFrames(&h264type, iFrameInterval, frameRate);
  +    h264type.nPFrames = 0;  // 必须在这里重新设置一次，因为 setBFrames() 会修改 h264type.nPFrames 的值
       if (h264type.nBFrames != 0) {
```

## 加速问题重现 -- 有问题的MP4
* 修改后持续录影 40 多分钟就能重现问题，基本上可以确认这就是问题的原因了

![](idr_pic_id_reproduct_overflow.png)

## 加速问题重现 -- 没有问题的MP4

![](idr_pic_id_reproduct_ok.png)


# 问题解决
## 问题解决
* 高通技术支持工程师修正后提供新的 venus firmware，替换
android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/ 路径下的 venus-v1.* 文件

```
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/firmware/venus/unsigned/venus-v1.b00
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/firmware/venus/unsigned/venus-v1.b01
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/firmware/venus/unsigned/venus-v1.b02
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/firmware/venus/unsigned/venus-v1.b03
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/firmware/venus/unsigned/venus-v1.b04
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/firmware/venus/unsigned/venus-v1.mbn
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/firmware/venus/unsigned/venus-v1.mdt
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/system/etc/firmware/venus-v1.b00
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/system/etc/firmware/venus-v1.b01
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/system/etc/firmware/venus-v1.b02
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/system/etc/firmware/venus-v1.b03
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/system/etc/firmware/venus-v1.mbn
  android/vendor/qcom/proprietary/prebuilt_HY11/target/product/msm8952_64/system/etc/firmware/venus-v1.mdt
```

## Fixed Verify
* 更新 firmware 后重新煲机验证，发现 idr_pic_id 超过 65535 后，会重新从 0 开始递增。
原来播放出现马赛克的问题没有重现，问题解决

![](idr_pic_id-65535.png)

## Fixed Verify

![](idr_pic_id-0.png)

# 总结
## 总结
* 请别人协助处理问题之前，自己要做足准备工作，要有自己的分析和验证，缩小和定位问题的范围，
确定是自己无法解决的领域，才有充分的理由请别人协助，否则即使不招到拒绝，也不利于问题的分析和解决
* IC原厂有丰富的问题处理经验和积累，我们将问题描述得清楚和专业，原厂就容易找到处理过的相同问题案例，问题很快就得到解决
* 如果没有处理过的相同案例，要硬着去分析Codec的各项数据找到疑点，这个工作量还是比较大的，
而且要求对Codec Spec非常熟悉， 同时找到专业的分析工具也很重要，否则可能无法看到需要的数据
* 音视频方面无论是媒体文件、压缩工具和播放器，经常会出现兼容性的问题，遇到问题要先用
不同的工具做交叉验证

## The End

![](thank_you.jpg)

# nginx-rtmp-stream-failover

This setup should configure the "localhost" to receive an rtmp stream and relay it up to n-ary servers (non-synchronous).

Each "push" may specify unique URL to push to and a unique scale. If a scale is specified, the output to that URL is scaled using ffmpeg.

**NOTE**: At this time, only one or two URLs are supported.

## How it works

## Recommended OBS settings.

When using OBS to stream through an rtmp relay to YouTube, some settings have to be set by hand:

- "Stream" -> "Server": `rtmp://.../live` (replacing "..." with the IP address of the destination)*
- "Output" -> "Streaming" ->
    "Bitrate" -> `6800 Kbps` (this is recommended by YouTube)
    "Keyframe Interval" -> `4 s` (this is recommended by YouTube)
    "CPU Usage Preset" -> `veryfast`




\* Some tutorials will suggest using something random for the app name (in place of "live") as a type of password; however, unless SSL is used (rtmpS), the communication is not encrypted and it should only take a little packet snooping to discover the path. Some better options include specifying which IPs are allow to publish and using SSL.

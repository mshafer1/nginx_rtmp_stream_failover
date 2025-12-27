# nginx-rtmp-stream-failover

This setup should configure the "localhost" to receive an rtmp stream and relay it up to n-ary servers (non-synchronous).

Each "push" may specify unique URL to push to and a unique scale. If a scale is specified, the output to that URL is scaled using ffmpeg.

**NOTE**: At this time, only one or two URLs are supported.

# ⚠️ in progress ⚠️

This repo is in pre-release stage

## How it works

### High Level:
[NGINX](https://nginx.org/en/) is installed with [the rtmp module](https://docs.nginx.com/nginx/admin-guide/dynamic-modules/rtmp/) (via, [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module)). NGINX is configured to allow pushing to it from certain IPs (configurable). A script runs on the system that pulls stream from nginx and sends it to the first "push". When that fails, the script starts pushing to the second "push" URL until it is able to get the first one to start and stay running again.

### Flow diagram:


```
+-----------+         +---------+        +----------------+             +----------------------+
|           |         |         |        |                |             |                      |
|   Input   +-------->|  NGINX  +---+--->|  ffmpeg (main) +------------>| Stream server (main) |
|           |         |         |   |    |                |             |                      |
+-----------+         +---------+   |    +----------------+             +----------------------+
                                    |          (xor)                                                 
                                    |    +----------------+             +----------------------+
                                    |    |                |             |                      |
                                    +--->|  ffmpeg (alt)  +------------>| Stream server (alt)  |
                                         |                |             |                      |
                                         +----------------+             +----------------------+
```

### Notable implementation:
- `push` is a collection of "please take the stream, scale it, and send it to this url". (see `inventory.yaml.template`).
- Each ffmpeg instance is set to scale the image as specified in the corresponding push.
- On start, the service assigns networking routes based on the "interface_grep" for each `push` (if provided). This means that the main and alt streams can be forced to go out different interfaces (e.g., wired vs wifi)

## Example inventory file

For configuring the system the repo is cloned on:
```yaml
all:
  hosts:
    multistream_server:
      ansible_connection: local
      ansible_become_pass: ...

      multistream_fail_over__allowed_ips:
        - '127.0.0.1'
        - '192.168.1.2' # also allow this IP to push to the stream
      multistream_pushes: [] # don't push from nginx
      multistream_execs: [] # don't downscale from nginx
      failover_pushes:
        - scale: '-1:-1' # don't change scale
          url: rtmp://a.rtmp.youtube.com/live2/... # example. Replace "..." with your stream key
          interface_grep: 'eth*' # Make sure to use Ethernet port
        - scale: '-2:720' # tell ffmpeg to downscale to 720p and calculate the width such that it's divisible by 2
          url: rtmp://b.rtmp.youtube.com/live2/.../?backup=1 # example. Replace "..." with your stream key
          interface_grep: 'wlan*' # Make sure to use Wi-Fi connection
  children:
    multistream_failover:
      hosts:
        multistream_server: # name must match line 3
```

## Recommended OBS settings.

When using OBS to stream through an rtmp relay to YouTube, some settings have to be set by hand:

- "Stream" -> "Server": `rtmp://.../live` (replacing "..." with the IP address of the destination)*
- "Output" -> "Streaming" ->
 
    - "Bitrate" -> `6800 Kbps` (this is recommended by YouTube)

    - "Keyframe Interval" -> `4 s` (this is recommended by YouTube)
    
    - "CPU Usage Preset" -> `veryfast`




\* Some tutorials will suggest using something random for the app name (in place of "live") as a type of password; however, unless SSL is used (rtmpS), the communication is not encrypted and it should only take a little packet snooping to discover the path. Some better options include specifying which IPs are allow to publish and using SSL.
